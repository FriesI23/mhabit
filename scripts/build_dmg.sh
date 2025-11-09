# Copyright 2024 Fries_I23
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

FLAVOR="f_generic"

while [[ $# -gt 0 ]]; do
  case $1 in
    --flavor)
      FLAVOR="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is only intended for macOS systems."
    exit 1
fi

if ! command -v appdmg &>/dev/null; then
    echo "Error: appdmg command not found."
    exit 1
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
APP_ORGPATH=$HERE/../build/macos/Build/Products/Release
if [[ -n "$FLAVOR" ]]; then
  APP_FILEPATH=$HERE/../build/macos/Build/Products/Release-${FLAVOR}/mhabit.app
else
  APP_FILEPATH=$APP_ORGPATH
fi
DMG_DIR=$HERE/../build/macos_dmg
DMG_FILEPATH=$DMG_DIR/mhabit-$FLAVOR-$(date +"%Y-%m-%d-%H-%M-%S").dmg

if [ -f "$APP_FILEPATH" ] || [ -d "$APP_FILEPATH" ]; then
  echo "App $APP_FILEPATH exists, cleaning..."
  rm -fr "$APP_FILEPATH"
fi

echo "app file path: $APP_FILEPATH"
echo "dmg outp path: $DMG_FILEPATH"
if [[ -n "$FLAVOR" ]]; then
  echo "building use flavor: $FLAVOR"
  flutter build macos --flavor "$FLAVOR"
  if [  -d "$APP_ORGPATH" ]; then
    rm -fr $APP_ORGPATH
  fi
  mkdir -p "$APP_ORGPATH"
  cp -rf $APP_FILEPATH $APP_ORGPATH
else
  flutter build macos
fi

if [ ! -d "$DMG_DIR" ]; then
    mkdir -p "$DMG_DIR"
fi
appdmg $HERE/../installers/dmg_creator/config.json $DMG_FILEPATH
