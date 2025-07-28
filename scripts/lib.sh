#!/bin/bash

function list_folders() {
  for dir in "$@"; do
    if [ -d "$dir" ]; then
      echo "$dir"
    fi
  done
}

function changed_files() {
  local dir="$1"
  git diff --name-only origin/main | grep "$dir/" | cut -d'/' -f1-3 | uniq
}
