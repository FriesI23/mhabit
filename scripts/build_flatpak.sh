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

if [[ "$(uname)" != "Linux" ]]; then
    echo "Error: This script is only intended for linux systems." >&2
    exit 1
fi

check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' command not found." >&2
        exit 1
    fi
}

check_flatpak_app() {
    local app_id="$1"
    if ! flatpak info "$app_id" &>/dev/null; then
        echo "Error: Flatpak app '$app_id' is not installed." >&2
        exit 1
    fi
}

check_command flutter
check_command flatpak
check_flatpak_app org.flatpak.Builder

HERE="$(cd "$(dirname "$0")" && pwd)"

flutter clean
flutter pub get
flutter build linux --release

set -x

mkdir -p "$HERE/../build/linux/flatpak_builder"
cd "$HERE/../build/linux/flatpak_builder"
flatpak run org.flatpak.Builder \
    --force-clean build-dir \
    --repo=repo-dir \
    --default-branch=main \
    "$HERE/../configs/flatpak_builder/io.github.friesi23.mhabit.yml"
flatpak build-bundle repo-dir mhabit.flatpak io.github.friesi23.mhabit main

set +x
