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

flutter pub run flutter_launcher_icons --file flutter_launcher_momo_icons.yaml

flutter pub run flutter_launcher_icons

SOURCE_FILE="configs/flutter_launcher_incons/ic_launcher.xml"
TARGET_FILE="android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "source file not exist: $SOURCE_FILE"
    exit 1
fi

cat "$SOURCE_FILE" >"$TARGET_FILE"
echo "copied to: $target_file."
