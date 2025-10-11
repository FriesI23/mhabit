#!/bin/bash
#
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

#!/bin/bash

PREFIX=""

read_cmdopts() {

  while getopts ":p:" opt; do
    case $opt in
    p)
      PREFIX="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    esac
  done
}

check_command() {
  local cmd="$1"
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' command not found." >&2
    exit 1
  fi
}

read_cmdopts "$@"
check_command xmlstarlet

HERE="$(cd "$(dirname "$0")" && pwd)"
META_PATH="$HERE/../configs/flatpak_builder/io.github.friesi23.mhabit.metainfo.xml"
RELEASE_META_PATH="$HERE/../flatpak/io.github.friesi23.mhabit.metainfo.xml"

TIMESTAMP=$(date +"%Y-%m-%d")

VERSION=$(awk -F': ' '/^version:/ {gsub(/\r/, "", $2); print $2; exit}' pubspec.yaml)
if [[ "$VERSION" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-pre(\.[0-9]+)?(\+[0-9]+)?$ ]]; then
  BASE_VERSION="${BASH_REMATCH[1]}"
  PRE_SUFFIX="${BASH_REMATCH[2]}"
  BUILD_META="${BASH_REMATCH[3]}"
  VERSION_TAG="${PREFIX}pre${PRE_SUFFIX}-v${BASE_VERSION}${BUILD_META}"
else
  VERSION_TAG="${PREFIX}v$VERSION"
fi

DETAILS_URL="https://github.com/FriesI23/mhabit/releases/tag/$VERSION_TAG"
echo "version: $VERSION"
echo "tag: $VERSION_TAG"
echo "date: $TIMESTAMP"
echo "details: $DETAILS_URL"
echo "meta-path: $META_PATH"
echo "release-meta-path: $RELEASE_META_PATH"
echo "---"

check_metainfo() {
  local meta_path="$1"
  local cli_cmd=""

  if [[ "$(uname)" != "Linux" ]]; then
    return
  fi

  if flatpak info org.freedesktop.appstream.cli &>/dev/null; then
    cli_cmd="flatpak run org.freedesktop.appstream.cli"
  elif command -v appstreamcli &>/dev/null; then
    cli_cmd="appstreamcli"
  else
    echo "No appstreamcli found (flatpak or system)"
    return
  fi

  echo "checking metainfo at: $meta_path..."
  if ! $cli_cmd validate --pedantic --format yaml "$meta_path"; then
    exit 1
  fi
}

echo "updating new version in $META_PATH..."
EXIST=$(xmlstarlet sel -t -v "count(/component/releases/release[@version='$VERSION'])" "$META_PATH")
if [ "$EXIST" -ne 0 ]; then
  echo "version $VERSION already exists, skipping add."
else
  RELEASES_EXIST=$(xmlstarlet sel -t -v "count(/component/releases)" "$META_PATH")
  if [ "$RELEASES_EXIST" -eq 0 ]; then
    xmlstarlet ed -L \
      -d "/component/releases" \
      -s "/component" -t elem -n releases -v "" \
      -s "/component/releases" -t elem -n release -v "" \
      -i "/component/releases/release" -t attr -n version -v "$VERSION" \
      -i "/component/releases/release" -t attr -n date -v "$TIMESTAMP" \
      -s "/component/releases/release" -t elem -n url -v "$DETAILS_URL" \
      -i "/component/releases/release/url" -t attr -n type -v "details" \
      "$META_PATH"
  else
    xmlstarlet ed -L \
      -i "/component/releases/release[1]" -t elem -n release_tmp -v "" \
      -i "/component/releases/release_tmp" -t attr -n version -v "$VERSION" \
      -i "/component/releases/release_tmp" -t attr -n date -v "$TIMESTAMP" \
      -s "/component/releases/release_tmp" -t elem -n url -v "$DETAILS_URL" \
      -i "/component/releases/release_tmp/url" -t attr -n type -v "details" \
      -r "/component/releases/release_tmp" -v release \
      "$META_PATH"
  fi
fi

check_metainfo $META_PATH

echo "processing $RELEASE_META_PATH..."
PRE_SUFFIX_XPATH="contains(@version, '-pre')"
NEW_CONTENT=$(xmlstarlet ed -d "/component/releases/release[$PRE_SUFFIX_XPATH]" "$META_PATH")
OLD_CONTENT=$(cat "$RELEASE_META_PATH")
if [ "$NEW_CONTENT" != "$OLD_CONTENT" ]; then
  echo "$NEW_CONTENT" >"$RELEASE_META_PATH"
else
  echo "no changes after removal, skipping update."
fi

check_metainfo $RELEASE_META_PATH
