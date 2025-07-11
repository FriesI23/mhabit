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

check_command flatpak
check_command flatpak-builder

HERE="$(cd "$(dirname "$0")" && pwd)"

flutter clean
flutter pub get
flutter build linux --release

mkdir -p "$HERE/../build/linux/flatpak_builder"
cd "$HERE/../build/linux/flatpak_builder"
flatpak-builder --force-clean build-dir "$HERE/../configs/flatpak_builder/io.github.friesi23.mhabit.yml" --repo=repo-dir
flatpak build-bundle repo-dir mhabit.flatpak io.github.friesi23.mhabit
