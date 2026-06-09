#!/usr/bin/env bash

# Copyright 2025 Fries_I23
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

if [[ -d "$REPO_ROOT/.flutter/bin" ]]; then
  export PATH="$REPO_ROOT/.flutter/bin:$PATH"
fi

cd "$REPO_ROOT"

if ! command -v poetry >/dev/null 2>&1; then
  echo "Poetry is required but not found in PATH." >&2
  exit 1
fi

before_status="$(mktemp)"
after_status="$(mktemp)"
before_diff="$(mktemp)"
after_diff="$(mktemp)"

cleanup() {
  rm -f "$before_status" "$after_status" "$before_diff" "$after_diff"
}
trap cleanup EXIT

git status --porcelain --untracked-files=all > "$before_status"
git diff --binary --no-ext-diff > "$before_diff"

bash "$SCRIPT_DIR/normalize_arb.sh"
bash "$SCRIPT_DIR/build_runner.sh"

git status --porcelain --untracked-files=all > "$after_status"
git diff --binary --no-ext-diff > "$after_diff"

if ! cmp -s "$before_status" "$after_status" || ! cmp -s "$before_diff" "$after_diff"; then
  echo "Detected changes after generation:"
  git status --short
  echo "------------------------"
  echo "Details:"
  git diff
  exit 1
fi