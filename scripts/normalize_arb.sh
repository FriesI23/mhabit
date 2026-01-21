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
L10N_REFS_FILE="$SCRIPT_PATH/../configs/l10n_refs.json"
echo "Normalizing ARB files from $L10N_DIR"
for file in $L10N_DIR/*.arb; do
    if [ -f "$file" ]; then
        if [[ "$file" == "$TEMPLATE_FILE" ]]; then
            python $SCRIPT_PATH/normalize_arb.py \
                -i $file -t $TEMPLATE_FILE -o $file --refs $L10N_REFS_FILE \
                --indent 4
            _ERRCODE=$?
        else
            python $SCRIPT_PATH/normalize_arb.py \
                -i $file -t $TEMPLATE_FILE -o $file --refs $L10N_REFS_FILE \
                --indent 4 --ignore-empty-meta
            _ERRCODE=$?
        fi
        echo "Done[$_ERRCODE]: $file"
    fi
done
