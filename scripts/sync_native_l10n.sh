#!/usr/bin/env bash
# Copyright 2026 Fries_I23
# Licensed under the Apache License, Version 2.0.

set -euo pipefail

fill_native_strings() {
  local arb_dir="$1" output_root="$2" refs="$3" table_name="$4"
  local arb_files=("$arb_dir"/*.arb)
  if ((${#arb_files[@]} == 0)); then
    echo "No ARB files found in $arb_dir" >&2
    return 2
  fi

  if [[ "$CHECK" == 1 ]]; then
    echo "Checking $output_root..."
  else
    echo "Generating $output_root..."
  fi

  local arb locale native_locale status
  for arb in "${arb_files[@]}"; do
    locale="$(basename "$arb" .arb)"
    case "$locale" in
      zh) native_locale=zh-Hans ;;
      zh_hant|zh_Hant) native_locale=zh-Hant ;;
      *) native_locale="${locale//_/-}" ;;
    esac
    local args=(
      --input "$arb"
      --output "$output_root/$native_locale.lproj/$table_name"
      --refs "$refs"
    )
    [[ "$CHECK" != 1 ]] || args+=(--check)
    [[ "$locale" != en ]] || args+=(--require-sources)
    status=0
    "$POETRY_PYTHON" bin/fill_strings_from_arb.py "${args[@]}" || status=$?
    if ((status > 1)); then
      return "$status"
    elif ((status == 1)); then
      RESULT=1
    fi
  done
  return 0
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CHECK=0

if (($# > 1)); then
  echo "Usage: $0 [--check]" >&2
  exit 2
fi
case "${1:-}" in
  "") ;;
  --check) CHECK=1 ;;
  --help|-h) echo "Usage: $0 [--check]"; exit 0 ;;
  *) echo "Usage: $0 [--check]" >&2; exit 2 ;;
esac

if ! command -v poetry >/dev/null 2>&1; then
  echo "Poetry is required but not found in PATH." >&2
  exit 2
fi
cd "$SCRIPT_DIR/python-scripts"
POETRY_ENV_PATH="$(poetry env info --path)" || exit 2
POETRY_PYTHON="$POETRY_ENV_PATH/bin/python"
if [[ ! -x "$POETRY_PYTHON" ]]; then
  echo "Poetry environment python not found: $POETRY_PYTHON" >&2
  exit 2
fi
shopt -s nullglob
RESULT=0

# Native table calls.
fill_native_strings \
  "$REPO_ROOT/assets/l10n" \
  "$REPO_ROOT/ios/HabitWidget/Extension" \
  "$REPO_ROOT/configs/l10n_strings_refs.json" \
  "Localizable.strings"
# End native table calls.

exit "$RESULT"
