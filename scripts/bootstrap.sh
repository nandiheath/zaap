
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

# Function to wait for all pods in a namespace to be ready
wait_for_pods_ready() {
  local namespace=$1
  local timeout=${2:-300}  # Default timeout of 300 seconds (5 minutes)
  local interval=${3:-5}   # Default check interval of 5 seconds
  
  print_info "Waiting for pods in namespace '$namespace' to be ready (timeout: ${timeout}s)..."
  
  local end_time=$(($(date +%s) + timeout))
  
  while [ $(date +%s) -lt $end_time ]; do
    # Get all pods in the namespace
    local pods_status=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[*].status.phase}' 2>/dev/null)
    local containers_ready=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[*].status.containerStatuses[*].ready}' 2>/dev/null)
    
    # If no pods found yet, wait and try again
    if [ -z "$pods_status" ]; then
      print_info "No pods found in namespace '$namespace' yet. Waiting..."
      sleep $interval
      continue
    fi
    
    # Check if any pods are not Running
    if [[ "$pods_status" == *"Pending"* ]] || [[ "$pods_status" == *"Failed"* ]] || [[ "$pods_status" == *"Unknown"* ]]; then
      print_info "Some pods in namespace '$namespace' are not running yet. Waiting..."
      sleep $interval
      continue
    fi
    
    # Check if all containers are ready
    if [[ "$containers_ready" == *"false"* ]]; then
      print_info "Some containers in namespace '$namespace' are not ready yet. Waiting..."
      sleep $interval
      continue
    fi
    
    # All pods are Running and all containers are ready
    print_info "All pods in namespace '$namespace' are ready!"
    return 0
  done
  
  print_error "Timeout waiting for pods in namespace '$namespace' to be ready"
  kubectl get pods -n "$namespace"
  return 1
}

# Function to create namespace if it doesn't exist
create_namespace_if_not_exists() {
  if ! namespace_exists "$1"; then
    print_info "Creating namespace: $1"
    kubectl apply --server-side -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $1
EOF
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
create_namespace_if_not_exists "cert-manager"
create_namespace_if_not_exists "cilium-secrets"



# Create the secrets
if ! resource_exists "external-secrets" "secret" "onepassword-connect-token"; then
  print_info "Creating onepassword-connect-token secret in external-secrets namespace"
  TOKEN_VALUE=$(tr -d '\n' < credentials/1password/1password-token.txt)
  kubectl apply --server-side -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: onepassword-connect-token
  namespace: external-secrets
type: Opaque
stringData:
  token: "$TOKEN_VALUE"
EOF
else
  print_info "Secret onepassword-connect-token already exists in external-secrets namespace"
fi

if ! resource_exists "1password" "secret" "op-credentials"; then
  print_info "Creating op-credentials secret in 1password namespace"
  CREDENTIALS_VALUE=$(base64 -i credentials/1password/1password-credentials.json)
  kubectl apply --server-side -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: op-credentials
  namespace: 1password
type: Opaque
stringData:
  1password-credentials.json: "$CREDENTIALS_VALUE"
EOF
else
  print_info "Secret op-credentials already exists in 1password namespace"
fi


# Apply the bootstrap namespaces
print_info "Applying namespaces"
kubectl apply --server-side -f artifacts/infrastructure/cluster-namespaces

# Check if argocd is installed, if not, install it
if ! resource_exists "argocd" "deployment" "argocd-server"; then
  print_info "Installing ArgoCD"
  kubectl apply --server-side -f artifacts/infrastructure/argocd/
else
  print_info "ArgoCD is already installed"
fi

# Check if cert-manager is installed, if not, install it
if ! resource_exists "cert-manager" "deployment" "cert-manager"; then
  print_info "Installing cert-manager"
  kubectl apply --server-side -f artifacts/infrastructure/cert-manager/
else
  print_info "cert-manager is already installed"
fi

# Wait for cert-manager pods to be ready
wait_for_pods_ready "cert-manager"

# Check if cilium is installed, if not, install it
if ! resource_exists "kube-system" "daemonset" "cilium"; then
  print_info "Installing Cilium"
  kubectl apply --server-side -f artifacts/infrastructure/cilium/
else
  print_info "Cilium is already installed"
fi

# Check if external-secrets is installed, if not, install it
if ! resource_exists "external-secrets" "deployment" "external-secrets"; then
  print_info "Installing External Secrets Operator"
  kubectl apply --server-side -f artifacts/infrastructure/external-secrets/
else
  print_info "External Secrets Operator is already installed"
fi

# Wait for external-secrets pods to be ready
wait_for_pods_ready "external-secrets"

# Apply the 1Password Connect manifests
print_info "Applying 1Password Connect manifests"
kubectl apply --server-side -f artifacts/infrastructure/1password-connect/

# Apply the bootstrap manifests
print_info "Applying bootstrap manifests"
kubectl apply --server-side -f artifacts/infrastructure/bootstrap

print_info "Bootstrap completed successfully!"
print_info "You can now access ArgoCD and start deploying applications."
print_info "For more information, see the README.md file."
 

