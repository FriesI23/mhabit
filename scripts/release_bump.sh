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
# Wiki step 1 (Bump App Version) executor: confirms a version string in the
# terminal (logic lives in bin/bump_version.py), then runs
# flutter clean && make aio-full.
# See: docs/wiki/Dev꞉-Push-To-New-Version.md
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

POETRY_ENV_PATH="$(cd "$SCRIPT_DIR/python-scripts" && poetry env info --path)"
"$POETRY_ENV_PATH/bin/python" "$SCRIPT_DIR/python-scripts/bin/bump_version.py" "$@"

cd "$REPO_ROOT"
flutter clean
make aio-full
