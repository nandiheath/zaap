#!/bin/bash

set -euo pipefail

# Script to create a new application with Helm chart in the project
# This script will:
# 1. Create a folder under manifests/infrastructure or manifests/applications with a kustomization file for a Helm chart
# 2. Create an application definition in manifests/infrastructure/argocd-app-of-apps/apps

# Display help message
function show_help() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -n, --name         Application name (required)"
  echo "  -c, --chart        Helm chart name (required)"
  echo "  -r, --repo         Helm chart repository URL (required)"
  echo "  -v, --version      Helm chart version (required)"
  echo "  -s, --namespace    Kubernetes namespace (required)"
  echo "  -d, --description  Application description (optional)"
  echo "  -t, --type         Application type: infrastructure or application (default: infrastructure)"
  echo "  -h, --help         Show this help message"
  echo ""
  echo "Example:"
  echo "  $0 --name myapp --chart mychart --repo https://charts.example.com --version 1.0.0 --namespace myapp"
  echo "  $0 --name myapp --chart mychart --repo https://charts.example.com --version 1.0.0 --namespace myapp --type application"
}

# Parse command line arguments
APP_TYPE="infrastructure"  # Default to infrastructure

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -n|--name)
      APP_NAME="$2"
      shift 2
      ;;
    -c|--chart)
      CHART_NAME="$2"
      shift 2
      ;;
    -r|--repo)
      CHART_REPO="$2"
      shift 2
      ;;
    -v|--version)
      CHART_VERSION="$2"
      shift 2
      ;;
    -s|--namespace)
      NAMESPACE="$2"
      shift 2
      ;;
    -d|--description)
      DESCRIPTION="$2"
      shift 2
      ;;
    -t|--type)
      APP_TYPE="$2"
      if [[ "$APP_TYPE" != "infrastructure" && "$APP_TYPE" != "application" ]]; then
        echo "Error: --type must be either 'infrastructure' or 'application'"
        exit 1
      fi
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# Check required parameters
if [ -z "${APP_NAME:-}" ] || [ -z "${CHART_NAME:-}" ] || [ -z "${CHART_REPO:-}" ] || [ -z "${CHART_VERSION:-}" ] || [ -z "${NAMESPACE:-}" ]; then
  echo "Error: Missing required parameters"
  show_help
  exit 1
fi

# Set default description if not provided
if [ -z "${DESCRIPTION:-}" ]; then
  DESCRIPTION="Application for ${APP_NAME}"
fi

# Create directories
BASE_DIR="manifests/${APP_TYPE}"
SRC_DIR="manifests/${APP_TYPE}/${APP_NAME}"
RENDERED_DIR="artifacts/${APP_TYPE}/${APP_NAME}"
APP_OF_APPS_DIR="manifests/${APP_TYPE}/${APP_TYPE}-app-of-apps"

echo "Creating application directories..."
mkdir -p "${SRC_DIR}"
mkdir -p "manifests/${APP_TYPE}"  # Ensure parent directory exists

# Create kustomization.yaml
echo "Creating kustomization.yaml..."
cat > "${SRC_DIR}/kustomization.yaml" << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

helmCharts:
  - name: ${CHART_NAME}
    repo: ${CHART_REPO}
    releaseName: ${APP_NAME}
    namespace: ${NAMESPACE}
    version: ${CHART_VERSION}
EOF

# Create application definition
echo "Creating application definition..."
# Always create ArgoCD application in the infrastructure directory
mkdir -p "${APP_OF_APPS_DIR}/apps"
cat > "${APP_OF_APPS_DIR}/apps/${APP_NAME}.yaml" << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}
spec:
  source:
    path: artifacts/${APP_TYPE}/${APP_NAME}
  destination:
    namespace: ${NAMESPACE}
EOF

# Add the application to the argocd-app-of-apps kustomization
echo "Adding application to argocd-app-of-apps kustomization..."
KUSTOMIZATION_FILE="${APP_OF_APPS_DIR}/kustomization.yaml"
mkdir -p "$(dirname "${KUSTOMIZATION_FILE}")"  # Ensure directory exists

# Check if the application is already in the kustomization file
if grep -q "apps/${APP_NAME}.yaml" "${KUSTOMIZATION_FILE}"; then
  echo "Application ${APP_NAME} is already in the kustomization file."
else
  # Find the line number of the last resource entry
  LAST_RESOURCE=$(grep -n "^  - apps/" "${KUSTOMIZATION_FILE}" | tail -1 | cut -d: -f1)
  
  # Add the new application after the last resource entry
  sed -i '' "${LAST_RESOURCE}a\\
  - apps/${APP_NAME}.yaml" "${KUSTOMIZATION_FILE}"
  echo "Added ${APP_NAME} to the kustomization file."
fi

echo "Application ${APP_NAME} created successfully!"
echo "Source directory: ${SRC_DIR}"
echo "Application definition: manifests/infrastructure/argocd-app-of-apps/apps/${APP_NAME}.yaml"
echo "Rendered manifests will be in: ${RENDERED_DIR}"
echo ""
echo "The application will be automatically picked up by the argocd-app-of-apps application."
echo "Application type: ${APP_TYPE}"