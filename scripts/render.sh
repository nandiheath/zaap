#!/bin/bash
#
# Render script for generating Kubernetes manifests
# 
# This script has been enhanced to work reliably in CI environments:
# - Handles missing .env file gracefully
# - Provides debug output in CI environments
# - Includes robust error handling for git operations and external tools
# - Falls back to processing all applications if git history is not available
# - Supports both infrastructure and application manifests

set -Eeuo pipefail

# Default to infrastructure if not specified
MANIFEST_TYPE="infrastructure"
# Create a single temp directory for all interpolated manifests
TMP_MANIFESTS_ROOT="$(mktemp -d "/tmp/manifests.XXXXXX")"

dir_path=$(dirname "${BASH_SOURCE[0]}")

# shellcheck source=scripts/lib.sh
source "$dir_path/lib.sh"

function show_help() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  --all                Process all manifests"
  echo "  --app <name>         Process a specific app"
  echo "  --infra              Process infrastructure manifests (default)"
  echo "  --application        Process application manifests"
  echo "  -h, --help           Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                   Process changed manifests (defaults to infrastructure)"
  echo "  $0 --all --infra     Process all infrastructure manifests"
  echo "  $0 --all --application  Process all application manifests"
  echo "  $0 --app myapp --application  Process specific application manifest"
}

# Parse arguments
ALL_FLAG=false
APP_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      ALL_FLAG=true
      shift
      ;;
    --app)
      if [[ -n "${2:-}" ]]; then
        APP_NAME="$2"
        shift 2
      else
        echo "Error: --app requires a path argument" >&2
        exit 1
      fi
      ;;
    --infra)
      MANIFEST_TYPE="infrastructure"
      shift
      ;;
    --application)
      MANIFEST_TYPE="application"
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help
      exit 1
      ;;
  esac
done

# Set render directory based on manifest type
RENDER_DIR="artifacts/${MANIFEST_TYPE}"

# Create manifests directory if it doesn't exist
mkdir -p "manifests/${MANIFEST_TYPE}"

# Determine which manifests to process
if [[ "$ALL_FLAG" == "true" ]]; then
  manifests_list=$(list_folders manifests/${MANIFEST_TYPE}/*)
elif [[ -n "$APP_NAME" ]]; then
  manifests_list="manifests/${MANIFEST_TYPE}/${APP_NAME}"
else
  echo "Detecting changed manifests..."
  manifests_list=$(changed_files "manifests/${MANIFEST_TYPE}")
fi

SUBSTITUTION_VARIABLES=(
  ARGOCD_GITHUB_REPO
  ARGOCD_GITHUB_ORG
  VAULT
  ARGOCD_ADMIN_GITHUB_USER
)

if [[ -f "$dir_path/../config/.env" ]]; then
  echo "Loading non-secret identifiers from config/.env"
  set -a
  # shellcheck source=/dev/null
  source "$dir_path/../config/.env"
  set +a
fi

for variable in "${SUBSTITUTION_VARIABLES[@]}"; do
  if [[ -z "${!variable:-}" ]]; then
    echo "Error: required render variable $variable is unset or empty." >&2
    exit 1
  fi
done

printf 'Will substitute only:'
for variable in "${SUBSTITUTION_VARIABLES[@]}"; do printf ' %s' "\${${variable}}"; done
printf '\n'

interpolate_manifests() {
  local src_dir="$1"
  local dst_dir="$2"
  local src_file
  local rel_path
  local dst_file
  local content
  local variable
  local placeholder

  echo "Interpolating environment variables in manifests from $src_dir to $dst_dir"
  while IFS= read -r -d '' src_file; do
    rel_path="${src_file#"$src_dir"/}"
    dst_file="$dst_dir/$rel_path"
    mkdir -p "$(dirname "$dst_file")"
    content=$(<"$src_file")
    for variable in "${SUBSTITUTION_VARIABLES[@]}"; do
      placeholder="\${${variable}}"
      content="${content//"$placeholder"/"${!variable}"}"
      placeholder="\$${variable}"
      content="${content//"$placeholder"/"${!variable}"}"
    done
    printf '%s\n' "$content" > "$dst_file"
  done < <(find "$src_dir" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) -print0)
}

cleanup_tmp_manifests() {
  rm -rf "$TMP_MANIFESTS_ROOT"
}
trap cleanup_tmp_manifests EXIT

create_tmp_subdir() {
  local manifests="$1"
  local subdir
  subdir="$TMP_MANIFESTS_ROOT/$(basename "$manifests")"
  mkdir -p "$subdir"
  echo "$subdir"
}

for manifests in $manifests_list ; do
  echo "interpolating env vars in $manifests"
  tmp_manifests="$(create_tmp_subdir "$manifests")"
  interpolate_manifests "$manifests" "$tmp_manifests"
  echo "rendering manifests from $tmp_manifests"
  # Extract the app name from the manifest path (last part of the path)
  app_name=$(basename "$manifests")
  output_path="$RENDER_DIR/$app_name"
  rm -rf "$output_path"
  mkdir -p "$output_path"
  
  if ! command -v kustomize &> /dev/null; then
    echo "Error: kustomize command not found. Install the pinned Hermit toolchain first." >&2
    exit 1
  fi

  if ! command -v yq &> /dev/null; then
    echo "Error: yq command not found. Install the pinned Hermit toolchain first." >&2
    exit 1
  fi

  if ! kustomize_output=$(kustomize build --enable-helm "$tmp_manifests" 2>&1); then
    echo "Error: kustomize build failed for $tmp_manifests: $kustomize_output" >&2
    exit 1
  fi

  if ! printf '%s\n' "$kustomize_output" | yq -s '"'"$output_path/"'" + (.kind | downcase) + "_" + (.metadata.name | sub("\.","-"))'; then
    echo "Error: yq processing failed for $tmp_manifests" >&2
    exit 1
  fi
done