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

SCRIPT_PATH=$(dirname $0)
L10N_DIR="$SCRIPT_PATH/../assets/l10n"
TEMPLATE_FILE=$L10N_DIR/en.arb
echo "Normalizing ARB files from $L10N_DIR"
for file in $L10N_DIR/*.arb; do
    if [ -f "$file" ]; then
        python $SCRIPT_PATH/normalize_arb.py -i $file -t $TEMPLATE_FILE -o $file
        _ERRCODE=$?
        echo "Done[$_ERRCODE]: $file"
    fi
done
