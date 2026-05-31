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

set -euo pipefail

SCRIPT_PATH=$(dirname "$0")
REPO_ROOT=$(cd "$SCRIPT_PATH/.." && pwd)
TOOLS_DIR="$REPO_ROOT/tools"

if [[ -n "${DART:-}" ]]; then
    DART_BIN="$DART"
elif [[ -x "$REPO_ROOT/.flutter/bin/dart" ]]; then
    DART_BIN="$REPO_ROOT/.flutter/bin/dart"
elif command -v dart >/dev/null 2>&1; then
    DART_BIN=dart
else
    echo "Dart SDK not found." >&2
    exit 1
fi

cd "$TOOLS_DIR" || exit 1

run_icon_target() {
    "$DART_BIN" run bin/gen_icons.dart "$@"
}

run_icon_target \
    ../assets/icons/sort_icons \
    ../assets/fonts/sort_icons.otf \
    --output-class-file=../lib/theme/_icons/sort_icons.g.dart \
    --class-name=HabitSortIcons \
    --font-name=HabitSortIcons \
    --format

run_icon_target \
    ../assets/icons/calendar_icons \
    ../assets/fonts/cal_icons.otf \
    --output-class-file=../lib/theme/_icons/cal_icons.g.dart \
    --class-name=HabitCalIcons \
    --font-name=HabitCalIcons \
    --format

run_icon_target \
    ../assets/icons/progress_icons \
    ../assets/fonts/progress_icons.otf \
    --output-class-file=../lib/theme/_icons/progress_icons.g.dart \
    --class-name=HabitProgressIcons \
    --font-name=HabitProgressIcons \
    --format

run_icon_target \
    ../assets/icons/common_icons \
    ../assets/fonts/common_icons.otf \
    --output-class-file=../lib/theme/_icons/common_icons.g.dart \
    --class-name=CommonIcons \
    --font-name=CommonIcons \
    --format