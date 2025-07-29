#!/bin/bash
#
# Library of helper functions for the render script
# 
# This library has been enhanced to work reliably in CI environments:
# - Provides robust git operations that handle limited git history
# - Falls back to alternative methods when git commands fail
# - Ensures scripts don't fail due to git command errors

function list_folders() {
  for dir in "$@"; do
    if [ -d "$dir" ]; then
      echo "$dir"
    fi
  done
}

function changed_files() {
  local dir="$1"
  # Check if origin/main exists and is accessible
  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    git diff --name-only origin/main | grep -E "$dir/" | cut -d'/' -f1-3 | uniq || true
  else
    # Fallback to listing all application directories if origin/main is not accessible
    echo "Warning: Cannot access origin/main, falling back to processing all applications" >&2
    list_folders "$dir/applications/"*
  fi
}
