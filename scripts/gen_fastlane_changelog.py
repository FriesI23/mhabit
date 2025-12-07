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


changelog_pattern_base = r"##\s*([\d.]+(?:\+\d+){pre})\n\n(.+?(?=\n\n##|$))"


def iter_get_changelogs(changelog: str, with_pre: bool = False):
    pre_pattern = r"(?:-pre)?" if with_pre else ""
    changelog_pattern = changelog_pattern_base.format(pre=pre_pattern)
    changelog_compile = re.compile(changelog_pattern, re.DOTALL)
    matchs = changelog_compile.findall(changelog)
    for match in matchs:
        version = match[0].strip()
        content = match[1].strip()
        yield version, content


def get_version_code(version: str):
    version_parts = version.split("+")
    if len(version_parts) > 1:
        version_code = version_parts[1].split("-")[0]  # 去掉 -pre
        return int(version_code)
    else:
        return 1


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("changelog_path")
    parser.add_argument("-o", "--output_dir", required=True)
    parser.add_argument(
        "--with-pre", action="store_true", help="Include pre-release entries"
    )
    parser.add_argument("--force", action="store_true", help="Overwrite existing files")
    parser.add_argument(
        "--min-version-code",
        type=int,
        default=0,
        help="Ignore versions with version code less than this value",
    )
    return parser


if __name__ == "__main__":
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

    version_map = {}
    with open(changelog_path, "r") as fp:
        for version, content in iter_get_changelogs(fp.read(), args.with_pre):
            version_code = get_version_code(version)
            if version_code < args.min_version_code:
                continue
            if version_code in version_map:
                version_map[version_code] += os.linesep
                version_map[version_code] += content
            else:
                version_map[version_code] = content

    for version_code, version_content in version_map.items():
        file_path = os.path.join(output_dir, f"{version_code}.txt")
        if os.path.exists(file_path) and not args.force:
            print(f"skip existing file: {file_path}")
            continue

        with open(file_path, "w") as fp:
            print(f"write at: {file_path}")
            if not version_content.endswith("\n"):
                version_content += os.linesep
            fp.write(version_content)

    del version_map
