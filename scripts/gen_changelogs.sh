#!/usr/bin/env bash
# Copyright 2023 Fries_I23
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
SCRIPT_PATH=$(dirname $0)
PYTHON_SCRIPTS_DIR="$SCRIPT_PATH/python-scripts"
FAIL_FAST=0

while getopts ":F" opt; do
	case "$opt" in
		F) FAIL_FAST=1 ;;
		\?) echo "Unknown option: -$OPTARG" >&2; exit 2 ;;
	esac
done

shift $((OPTIND-1))
if [ "$FAIL_FAST" -eq 1 ]; then
	set -Eeuo pipefail
fi

if ! command -v poetry >/dev/null 2>&1; then
	echo "Poetry is required but not found in PATH." >&2
	exit 1
fi

POETRY_ENV_PATH=$(cd "$PYTHON_SCRIPTS_DIR" && poetry env info --path)
POETRY_PYTHON="$POETRY_ENV_PATH/bin/python"

if [ ! -x "$POETRY_PYTHON" ]; then
	echo "Poetry environment python not found: $POETRY_PYTHON" >&2
	exit 1
fi

echo "Generating fastlane changelog: en-US"
"$POETRY_PYTHON" "$PYTHON_SCRIPTS_DIR/bin/gen_fastlane_changelog.py" "$SCRIPT_PATH/../CHANGELOG.md" \
	-o "$SCRIPT_PATH/../fastlane/metadata/android/en-US/changelogs" --validate
echo "Generating fastlane changelog: zh-CN"
"$POETRY_PYTHON" "$PYTHON_SCRIPTS_DIR/bin/gen_fastlane_changelog.py" "$SCRIPT_PATH/../docs/CHANGELOG/zh.md" \
	-o "$SCRIPT_PATH/../fastlane/metadata/android/zh-CN/changelogs" --validate

echo "Generating f_store's fastlane changelog: en-US"
"$POETRY_PYTHON" "$PYTHON_SCRIPTS_DIR/bin/gen_fastlane_changelog.py" "$SCRIPT_PATH/../CHANGELOG.md" \
	-o "$SCRIPT_PATH/../android/app/src/f_store/fastlane/metadata/android/en-US/changelogs" \
	--min-version-code 125 --with-pre --validate
echo "Generating f_store's fastlane changelog: zh-CN"
"$POETRY_PYTHON" "$PYTHON_SCRIPTS_DIR/bin/gen_fastlane_changelog.py" "$SCRIPT_PATH/../docs/CHANGELOG/zh.md" \
	-o "$SCRIPT_PATH/../android/app/src/f_store/fastlane/metadata/android/zh-CN/changelogs" \
	--min-version-code 125 --with-pre --validate
