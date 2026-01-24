#!/bin/sh
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

echo "Generating fastlane changelog: en-US"
$SCRIPT_PATH/gen_fastlane_changelog.py $SCRIPT_PATH/../CHANGELOG.md \
    -o $SCRIPT_PATH/../fastlane/metadata/android/en-US/changelogs --validate
echo "Generating fastlane changelog: zh-CN"
$SCRIPT_PATH/gen_fastlane_changelog.py $SCRIPT_PATH/../docs/CHANGELOG/zh.md \
    -o $SCRIPT_PATH/../fastlane/metadata/android/zh-CN/changelogs --validate

echo "Generating f_store's fastlane changelog: en-US"
$SCRIPT_PATH/gen_fastlane_changelog.py $SCRIPT_PATH/../CHANGELOG.md \
    -o $SCRIPT_PATH/../android/app/src/f_store/fastlane/metadata/android/en-US/changelogs \
    --min-version-code 125 --with-pre --validate
echo "Generating f_store's fastlane changelog: zh-CN"
$SCRIPT_PATH/gen_fastlane_changelog.py $SCRIPT_PATH/../docs/CHANGELOG/zh.md \
    -o $SCRIPT_PATH/../android/app/src/f_store/fastlane/metadata/android/zh-CN/changelogs \
    --min-version-code 125 --with-pre --validate
