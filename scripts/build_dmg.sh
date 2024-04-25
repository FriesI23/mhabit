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

if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is only intended for macOS systems."
    exit 1
fi

if ! command -v appdmg &>/dev/null; then
    echo "Error: appdmg command not found."
    exit 1
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
APP_FILEPATH=$HERE/../build/macos/Build/Products/Release/mhabit.app
DMG_DIR=$HERE/../build/macos_dmg
DMG_FILEPATH=$DMG_DIR/mhabit-$(date +"%Y-%m-%d-%H-%M-%S").dmg

if [ -f "$APP_FILEPATH" ] || [ -d "$APP_FILEPATH" ]; then
    echo "App $APP_FILEPATH exists, cleaning..."
    rm -fr "$APP_FILEPATH"
fi
flutter build macos --release

if [ ! -d "$DMG_DIR" ]; then
    mkdir -p "$DMG_DIR"
fi
appdmg $HERE/../installers/dmg_creator/config.json $DMG_FILEPATH
