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
import re, os, logging
import argparse


changelog_pattern_base = r"##\s*([\d.]+(?:\+\d+){pre})\n\n(.+?(?=\n\n##|$))"


class CustomFormatter(logging.Formatter):
    LEVEL_MAP = {
        logging.INFO: "I",
        logging.WARNING: "W",
        logging.ERROR: "E",
        logging.CRITICAL: "F",
        logging.DEBUG: "D",
    }

    def format(self, record):
        level = self.LEVEL_MAP.get(record.levelno, "?")
        return f"[{level}]: {record.getMessage()}"


def set_logger():
    handler = logging.StreamHandler()
    handler.setFormatter(CustomFormatter())
    logging.basicConfig(level=logging.WARNING, handlers=[handler])


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


def validate_android_content(content: str, version_code: int) -> bool:
    if len(content) > 500:
        logging.warning(
            f"skip android changelog {version_code}: length {len(content)} > 500"
        )
        return False
    return True


def validate_darwin_content(content: str) -> bool:
    if re.search(r"(android|windows|linux)", content, re.IGNORECASE):
        logging.warning("skip darwin release notes: contains platform keywords")
        return False
    return True


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("changelog_path")
    parser.add_argument("-o", "--output-dir")
    parser.add_argument(
        "--darwin-output-dir",
        help="Write latest changelog to darwin release_notes.txt",
    )
    parser.add_argument(
        "--validate", action="store_true", help="Validate content before writing"
    )
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
    set_logger()
    parser = parse_args()
    args = parser.parse_args()
    changelog_path = args.changelog_path
    if not os.path.exists(changelog_path):
        logging.error(f"change log not exists: {changelog_path}")
        exit(-1)
    if not args.output_dir and not args.darwin_output_dir:
        logging.error("must set --output-dir or --darwin-output-dir")
        exit(-2)
    output_dir = args.output_dir
    if output_dir and not os.path.isdir(output_dir):
        logging.error(f"output dir is not dir: {output_dir}")
        exit(-3)
    darwin_output_dir = args.darwin_output_dir
    if darwin_output_dir:
        os.makedirs(darwin_output_dir, exist_ok=True)

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

    if not version_map:
        logging.info("no changelog entries matched")
        exit(0)

    if output_dir:
        for version_code in sorted(version_map):
            version_content = version_map[version_code]
            file_path = os.path.join(output_dir, f"{version_code}.txt")
            if os.path.exists(file_path) and not args.force:
                logging.info(f"skip existing file: {file_path}")
                continue
            if args.validate and not validate_android_content(
                version_content, version_code
            ):
                continue

            with open(file_path, "w") as fp:
                logging.info(f"write at: {file_path}")
                if not version_content.endswith(os.linesep):
                    version_content += os.linesep
                fp.write(version_content)

    if darwin_output_dir:
        latest_version_code = max(version_map)
        darwin_path = os.path.join(darwin_output_dir, "release_notes.txt")
        darwin_content = version_map[latest_version_code]
        if args.validate and validate_darwin_content(darwin_content):
            with open(darwin_path, "w") as fp:
                logging.info(f"write darwin release notes at: {darwin_path}")
                if not darwin_content.endswith(os.linesep):
                    darwin_content += os.linesep
                fp.write(darwin_content)

    del version_map
