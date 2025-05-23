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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dart run flutter_native_splash:create \
    --path "$SCRIPT_DIR/../configs/flutter_native_splash/flutter_native_splash.yaml"

# Flavors
# dart run flutter_native_splash:create \
#     --flavor f_dev \
#     --path "$SCRIPT_DIR/../configs/flutter_native_splash/flutter_native_splash-f_dev.yaml"

find "$SCRIPT_DIR/../ios/Runner" \
    \( -name "Info.plist" -o -name "*-Info.plist" \) \
    -exec plutil -convert xml1 {} \;
