#!/usr/bin/env python3
# coding: utf-8
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
import re, os
import argparse

changelog_pattern = r"##\s*([\d.+\-]+)\n\n(.+?(?=\n\n##|$))"
changelog_compile = re.compile(changelog_pattern, re.DOTALL)


def iter_get_changlogs(changlog: str):
    matchs = changelog_compile.findall(changlog)
    for match in matchs:
        version = match[0].strip()
        content = match[1].strip()
        yield version, content


def get_version_code(version: str):
    version_parts = version.split('+')
    if len(version_parts) > 1:
        version_code = version_parts[1]
        return int(version_code)
    else:
        return 1


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("changelog_path")
    parser.add_argument("-o", "--output_dir", required=True)
    return parser


if __name__ == '__main__':
    parser = parse_args()
    args = parser.parse_args()
    changelog_path = args.changelog_path
    if not os.path.exists(changelog_path):
        print(f"change log not exists: {changelog_path}")
        exit(-1)
    output_dir = args.output_dir
    if not os.path.isdir(output_dir):
        print(f"output dir is not dir: {output_dir}")
        exit(-2)
    if not os.path.exists(output_dir):
        print(f"dir not exist: {output_dir}")
        exit(-1)

    version_map = {}
    with open(changelog_path, 'r') as fp:
        for version, content in iter_get_changlogs(fp.read()):
            version_code = get_version_code(version)
            if version_code in version_map:
                version_map[version_code] += os.linesep
                version_map[version_code] += content
            else:
                version_map[version_code] = content

    for version_code, version_content in version_map.items():
        file_path = os.path.join(
            output_dir,
            '.'.join((str(version_code), 'txt')),
        )
        with open(file_path, 'w') as fp:
            print(f"write at: {file_path}")
            if not version_content.endswith('\n'):
                version_content += os.linesep
            fp.write(version_content)

    del version_map