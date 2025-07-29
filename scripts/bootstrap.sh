
#!/bin/bash

set -e

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if a namespace exists
namespace_exists() {
  kubectl get namespace "$1" &> /dev/null
}

# Function to check if a resource exists
resource_exists() {
  local namespace=$1
  local resource_type=$2
  local resource_name=$3
  
  kubectl get -n "$namespace" "$resource_type" "$resource_name" &> /dev/null
}

# Function to create namespace if it doesn't exist
create_namespace_if_not_exists() {
  if ! namespace_exists "$1"; then
    print_info "Creating namespace: $1"
    kubectl create namespace "$1"
  else
    print_info "Namespace $1 already exists"
  fi
}

# Check if credentials directory exists
if [ ! -d "credentials/1password" ]; then
  print_error "Credentials directory not found: credentials/1password"
  print_error "Please create the following directory structure and files:"
  print_error "  - credentials/1password/1password-token.txt: 1Password Connect token"
  print_error "  - credentials/1password/1password-credentials.json: 1Password Connect credentials"
  print_error "See the README.md for more information on setting up credentials."
  exit 1
fi

# Check if required credential files exist
if [ ! -f "credentials/1password/1password-token.txt" ]; then
  print_error "1Password Connect token file not found: credentials/1password/1password-token.txt"
  exit 1
fi

if [ ! -f "credentials/1password/1password-credentials.json" ]; then
  print_error "1Password Connect credentials file not found: credentials/1password/1password-credentials.json"
  exit 1
fi

# Create namespaces if they don't exist
create_namespace_if_not_exists "external-secrets"
create_namespace_if_not_exists "1password"
create_namespace_if_not_exists "argocd"

# Create the secrets
if ! resource_exists "external-secrets" "secret" "onepassword-connect-token"; then
  print_info "Creating onepassword-connect-token secret in external-secrets namespace"
  kubectl create secret generic onepassword-connect-token -n external-secrets \
    --from-literal=token="$(tr -d '\n' < credentials/1password/1password-token.txt)"
else
  print_info "Secret onepassword-connect-token already exists in external-secrets namespace"
fi

if ! resource_exists "1password" "secret" "op-credentials"; then
  print_info "Creating op-credentials secret in 1password namespace"
  kubectl create secret generic op-credentials -n 1password \
    --from-literal=1password-credentials.json="$(base64 -i credentials/1password/1password-credentials.json)"
else
  print_info "Secret op-credentials already exists in 1password namespace"
fi

# Check if external-secrets is installed, if not, install it
if ! resource_exists "external-secrets" "deployment" "external-secrets"; then
  print_info "Installing External Secrets Operator"
  kubectl apply -f artifacts/external-secrets/
else
  print_info "External Secrets Operator is already installed"
fi

# Check if argocd is installed, if not, install it
if ! resource_exists "argocd" "deployment" "argocd-server"; then
  print_info "Installing ArgoCD"
  kubectl apply -f artifacts/argocd/
else
  print_info "ArgoCD is already installed"
fi

# Apply the 1Password Connect manifests
print_info "Applying 1Password Connect manifests"
kubectl apply -f artifacts/1password-connect/

# Apply the bootstrap manifests
print_info "Applying bootstrap manifests"
kubectl apply -f artifacts/bootstrap/

print_info "Bootstrap completed successfully!"
print_info "You can now access ArgoCD and start deploying applications."
print_info "For more information, see the README.md file."
 

