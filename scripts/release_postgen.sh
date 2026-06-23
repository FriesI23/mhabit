#!/usr/bin/env bash
# Copyright 2026 Fries_I23
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
#
# Wiki steps 4-6 executor: fastlane (Android), Apple platform release notes
# (stable only), and Flatpak/Flathub metainfo generation. Sequencing logic
# lives in bin/release_postgen.py.
# See: docs/wiki/Dev꞉-Push-To-New-Version.md
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
PYTHON_SCRIPTS_DIR="$REPO_ROOT/scripts/python-scripts"

MODE="${1:-}"
if [[ "$MODE" != "--release" && "$MODE" != "--pre" ]]; then
	echo "Usage: $0 --release | --pre" >&2
	exit 2
fi

if ! command -v poetry >/dev/null 2>&1; then
	echo "Poetry is required but not found in PATH." >&2
	exit 1
fi

cd "$PYTHON_SCRIPTS_DIR"
POETRY_PYTHON="$(poetry env info --path)/bin/python"

if [[ ! -x "$POETRY_PYTHON" ]]; then
	echo "Poetry environment python not found: $POETRY_PYTHON" >&2
	exit 1
fi

"$POETRY_PYTHON" bin/release_postgen.py "$MODE"
