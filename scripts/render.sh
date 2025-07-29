#!/bin/bash

set -oeu pipefail

RENDER_DIR="artifacts"
# Create a single temp directory for all interpolated manifests
TMP_MANIFESTS_ROOT="$(mktemp -d "/tmp/manifests.XXXXXX")"

dir_path=$(dirname "${BASH_SOURCE[0]}")

source "$dir_path/lib.sh"

if [[ $# -eq 0 ]]; then
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
if [[ -f "$dir_path/../config/.env" ]]; then
  echo "Loading environment variables from config/.env"
  set -a
  source "$dir_path/../config/.env"
  set +a
else
  echo "Warning: config/.env file not found, continuing without it"
fi

interpolate_manifests() {
  local src_dir="$1"
  local dst_dir="$2"
  echo "Interpolating environment variables in manifests from $src_dir to $dst_dir"
  # Use envsubst to replace environment variables in YAML files
  find "$src_dir" -type f -name "*.yaml" -exec sh -c 'rel_path="${1#"$2"/}"; dst="$3/$rel_path"; mkdir -p "$(dirname "$dst")"; envsubst < "$1" > "$dst"' _ {} "$src_dir" "$dst_dir" \;  
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
  rm -rf "$output_path/*"  # Clear previous output
  kustomize build --enable-helm "$tmp_manifests" | yq -s '"'"$output_path/"'" + (.kind | downcase) + "_" + (.metadata.name | sub("\.","-"))'
done