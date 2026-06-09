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

SCRIPT_PATH="$(cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_PATH/.." && pwd)"
PYTHON_SCRIPTS_DIR="$REPO_ROOT/scripts/python-scripts"

if ! command -v poetry >/dev/null 2>&1; then
    echo "Poetry is required but not found in PATH." >&2
    exit 1
fi

cd "$PYTHON_SCRIPTS_DIR"
POETRY_PYTHON="$(poetry env info --path)/bin/python"

if [ ! -x "$POETRY_PYTHON" ]; then
    echo "Poetry environment python not found: $POETRY_PYTHON" >&2
    exit 1
fi

L10N_DIR="$REPO_ROOT/assets/l10n"
TEMPLATE_FILE=$L10N_DIR/en.arb
L10N_REFS_FILE="$REPO_ROOT/configs/l10n_refs.json"


echo "Normalizing ARB files from $L10N_DIR"
for file in "$L10N_DIR"/*.arb; do
    if [ -f "$file" ]; then
        if [ "$file" = "$TEMPLATE_FILE" ]; then
            "$POETRY_PYTHON" bin/normalize_arb.py \
                -i "$file" -t "$TEMPLATE_FILE" -o "$file" --refs "$L10N_REFS_FILE" \
                --indent 4
            _ERRCODE=$?
        else
            "$POETRY_PYTHON" bin/normalize_arb.py \
                -i "$file" -t "$TEMPLATE_FILE" -o "$file" --refs "$L10N_REFS_FILE" \
                --indent 4 --ignore-empty-meta
            _ERRCODE=$?
        fi
        echo "Done[$_ERRCODE]: $file"
    fi
done
