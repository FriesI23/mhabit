#!/usr/bin/env bash

# Copyright 2026 Fries_I23
# Licensed under the Apache License, Version 2.0.

set -euo pipefail

case "${1:-}" in
  format) formatter_args=(format --in-place) ;;
  check) formatter_args=(lint --strict) ;;
  *) echo "Usage: bash scripts/swift_format.sh {format|check}" >&2; exit 64 ;;
esac
if [[ $# -ne 1 ]]; then
  echo "Expected exactly one mode: format or check." >&2
  exit 64
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Git does not recurse into submodules. Include new, non-ignored sources as well
# as tracked sources; use NUL delimiters so paths with spaces remain intact.
file_list="$(mktemp)"
trap 'rm -f "$file_list"' EXIT
git ls-files --cached --others --exclude-standard --deduplicate -z -- '*.swift' > "$file_list"
files=()
while IFS= read -r -d '' path; do
  case "$path" in
    *.g.swift|*/GeneratedPluginRegistrant.swift|GeneratedPluginRegistrant.swift|\
    .flutter/*|Pods/*|*/Pods/*|build/*|*/build/*|.build/*|*/.build/*) continue ;;
  esac
  # A tracked deletion or symlink must not make us read outside the source set.
  if [[ -f "$path" && ! -L "$path" ]]; then
    files+=("$path")
  fi
done < "$file_list"

if [[ ${#files[@]} -eq 0 ]]; then
  exit 0
fi
swift format "${formatter_args[@]}" --configuration "$REPO_ROOT/.swift-format" "${files[@]}"
