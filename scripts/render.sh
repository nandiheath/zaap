#!/bin/bash
#
# Render script for generating Kubernetes manifests
# 
# This script has been enhanced to work reliably in CI environments:
# - Handles missing .env file gracefully
# - Provides debug output in CI environments
# - Includes robust error handling for git operations and external tools
# - Falls back to processing all applications if git history is not available

# Enable debug output in CI environment
if [[ "${CI:-}" == "true" ]]; then
  set -x
fi

set -oeu pipefail

RENDER_DIR="artifacts"
# Create a single temp directory for all interpolated manifests
TMP_MANIFESTS_ROOT="$(mktemp -d "/tmp/manifests.XXXXXX")"

dir_path=$(dirname "${BASH_SOURCE[0]}")

source "$dir_path/lib.sh"

if [[ $# -eq 0 ]]; then
  echo "Detecting changed manifests..."
  manifests_list=$(changed_files "manifests")
else
  case "$1" in
    --all)
      manifests_list=$(list_folders manifests/applications/*)
      ;;
    --app)
      if [[ -n "${2:-}" ]]; then
        manifests_list="manifests/applications/${2}"
      else
        echo "Error: --app requires a path argument" >&2
        exit 1
      fi
      ;;
    *)
      manifests_list=$(changed_files "manifests")
      ;;
  esac
fi

# Load environment variables from config/.env if it exists
# In CI environments, .env file might not be present
ENV_VARS_TO_SUBST=""
if [[ -f "$dir_path/../config/.env" ]]; then
  echo "Loading environment variables from config/.env"
  set -a
  source "$dir_path/../config/.env"
  set +a
  
  # Extract variable names from .env file and format them for envsubst
  # This will ignore comments and empty lines
  ENV_VARS_TO_SUBST=$(grep -v '^#' "$dir_path/../config/.env" | grep -v '^$' | sed -E 's/([^=]+)=.*/\${\1}/g' | tr '\n' ' ')
  echo "Will only substitute the following environment variables: $ENV_VARS_TO_SUBST"
else
  echo "Warning: config/.env file not found, continuing without it"
fi

interpolate_manifests() {
  local src_dir="$1"
  local dst_dir="$2"
  echo "Interpolating environment variables in manifests from $src_dir to $dst_dir"
  # Use envsubst to replace only the environment variables defined in .env
  find "$src_dir" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) -exec sh -c 'rel_path="${1#"$2"/}"; dst="$3/$rel_path"; mkdir -p "$(dirname "$dst")"; envsubst "$4" < "$1" > "$dst"' _ {} "$src_dir" "$dst_dir" "$ENV_VARS_TO_SUBST" \;  
}

cleanup_tmp_manifests() {
  rm -rf "$TMP_MANIFESTS_ROOT"
}
trap cleanup_tmp_manifests EXIT

create_tmp_subdir() {
  local manifests="$1"
  local subdir="$TMP_MANIFESTS_ROOT/$(basename "$manifests")"
  mkdir -p "$subdir"
  echo "$subdir"
}

for manifests in $manifests_list ; do
  echo "interpolating env vars in $manifests"
  tmp_manifests="$(create_tmp_subdir "$manifests")"
  interpolate_manifests "$manifests" "$tmp_manifests"
  echo "rendering manifests from $tmp_manifests"
  output_path="$RENDER_DIR/$(echo "$manifests" | cut -d'/' -f3-4)"
  mkdir -p "$output_path"
  rm -rf $output_path/*  # Clear previous output
  
  # Check if kustomize is available
  if ! command -v kustomize &> /dev/null; then
    echo "Error: kustomize command not found. Please install kustomize." >&2
    echo "Skipping kustomize build for $tmp_manifests"
    continue
  fi
  
  # Check if yq is available
  if ! command -v yq &> /dev/null; then
    echo "Error: yq command not found. Please install yq." >&2
    echo "Skipping manifest rendering for $tmp_manifests"
    continue
  fi
  
  # Run kustomize and yq with error handling
  if ! kustomize_output=$(kustomize build --enable-helm "$tmp_manifests" 2>&1); then
    echo "Warning: kustomize build failed for $tmp_manifests: $kustomize_output" >&2
    continue
  fi
  
  echo "$kustomize_output" | yq -s '"'"$output_path/"'" + (.kind | downcase) + "_" + (.metadata.name | sub("\.","-"))' || {
    echo "Warning: yq processing failed for $tmp_manifests" >&2
  }
done