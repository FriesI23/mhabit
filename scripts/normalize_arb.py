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

import copy
import json
import typing as t
import argparse as ap

from collections import OrderedDict


T_JSON = dict[str, t.Optional[object]]


def format_arb(
    input_filepath: str,
    output_filepath: t.Optional[str] = None,
    template_filepath: t.Optional[str] = None,
    force_use_template_metadata: bool = False,
    indent: t.Optional[int] = None,
):
    with open(input_filepath, "r") as fp:
        input = json.load(fp, object_pairs_hook=OrderedDict)
        if not template_filepath:
            template = copy.deepcopy(input)
        else:
            with open(template_filepath, "r") as fp:
                template = json.load(fp)
        output = _format_arb(
            input=input,
            template=template,
            force_use_template_metadata=force_use_template_metadata,
        )

    if output_filepath:
        with open(output_filepath, "w") as fp:
            json.dump(output, fp=fp, indent=indent, ensure_ascii=False)
            fp.write("\n")
    else:
        print(json.dumps(output, indent=indent, ensure_ascii=False))


def _format_arb(
    input: T_JSON,
    template: T_JSON,
    force_use_template_metadata: bool,
) -> T_JSON:
    output = OrderedDict()
    for key in template:
        if key.startswith("@@"):
            output[key] = input[key]
            continue
        if key.startswith("@") or key not in input:
            continue
        output[key] = input[key]
        meta_key = f"@{key}"
        meta_value = input.get(meta_key)
        if not meta_value:
            template_meta_val = template.get(meta_key)
            output[meta_key] = template_meta_val or {}
        elif force_use_template_metadata and meta_key in template:
            output[meta_key] = template[meta_key]
        else:
            output[meta_key] = meta_value
    return output


def parse_args() -> ap.ArgumentParser:
    parser = ap.ArgumentParser()
    parser.add_argument("-i", "--input", type=str, required=True)
    parser.add_argument("-o", "--output", type=str)
    parser.add_argument("-t", "--template", type=str)
    parser.add_argument("--indent", type=int, default=2)
    parser.add_argument("--force-template", action=ap.BooleanOptionalAction)
    return parser


def main():
    parser = parse_args()
    args = parser.parse_args()
    input_filepath = args.input  # type: str
    output_filepath = args.output  # type: str
    template_filepath = args.template  # type: str
    indent = args.indent  # type: int
    force_template = args.force_template  # type: bool
    format_arb(
        input_filepath=input_filepath,
        output_filepath=output_filepath,
        template_filepath=template_filepath,
        force_use_template_metadata=force_template,
        indent=indent,
    )


if __name__ == "__main__":
    main()
