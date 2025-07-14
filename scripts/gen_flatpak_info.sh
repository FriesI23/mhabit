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

check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' command not found." >&2
        exit 1
    fi
}

check_command xmlstarlet

HERE="$(cd "$(dirname "$0")" && pwd)"
META_PATH="$HERE/../configs/flatpak_builder/io.github.friesi23.mhabit.metainfo.xml"

TIMESTAMP=$(date +"%Y-%m-%d")
VERSION=$(grep -E '^version:' pubspec.yaml | head -n1 | cut -d':' -f2- | xargs)
DETAILS_URL="https://github.com/FriesI23/mhabit/blob/main/CHANGELOG.md"
echo "version: $VERSION"
echo "date: $TIMESTAMP"
echo "meta-path: $META_PATH"

echo "updating new version in metainfo.xml..."
xmlstarlet ed -L \
    -d "/component/releases" \
    -s "/component" -t elem -n releases -v "" \
    -s "/component/releases" -t elem -n release -v "" \
    -i "/component/releases/release" -t attr -n version -v "$VERSION" \
    -i "/component/releases/release" -t attr -n date -v "$TIMESTAMP" \
    -s "/component/releases/release" -t elem -n url -v "$DETAILS_URL" \
    -i "/component/releases/release/url" -t attr -n type -v "details" \
    "$META_PATH"

if [[ "$(uname)" == "Linux" && -x "$(command -v appstreamcli)" ]]; then
    echo "checking metainfo.xml..."
    appstreamcli validate --pedantic --format yaml $META_PATH
fi
