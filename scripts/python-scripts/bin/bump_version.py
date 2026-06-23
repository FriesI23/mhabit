# Copyright 2026 Fries_I23
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
"""Confirm a suggested pubspec.yaml version and write it.

Entry points: scripts/release_bump.sh, scripts/release_bump.cmd. They run
this script first, then (only on success) run `flutter clean` and
`make aio-full` themselves, since both rely on PATH/PATHEXT resolution that
is more reliably handled by the native shell than by Python's subprocess.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

VERSION_RE = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+(-pre)?$")


def resolve_repo_root() -> Path:
    script_path = Path(__file__).resolve()
    for parent in script_path.parents:
        if (parent / "pubspec.yaml").is_file() and (parent / ".git").exists():
            return parent
    raise RuntimeError(
        f"Failed to resolve repository root from script path: {script_path}"
    )


REPO_ROOT = resolve_repo_root()
PUBSPEC = REPO_ROOT / "pubspec.yaml"


def log_info(message: str) -> None:
    print(f"[INFO] {message}")


def log_error(message: str) -> None:
    print(f"[ERROR] {message}", file=sys.stderr)


def read_current_version() -> str:
    for line in PUBSPEC.read_text(encoding="utf-8").splitlines():
        if line.startswith("version:"):
            return line.split(":", 1)[1].strip()
    raise RuntimeError(f"No version field found in {PUBSPEC}")


def write_version(version: str) -> None:
    lines = PUBSPEC.read_text(encoding="utf-8").splitlines(keepends=True)
    for i, line in enumerate(lines):
        if line.startswith("version:"):
            newline = "\n" if line.endswith("\n") else ""
            lines[i] = f"version: {version}{newline}"
            break
    else:
        raise RuntimeError(f"No version field found in {PUBSPEC}")
    PUBSPEC.write_text("".join(lines), encoding="utf-8")


def confirm_version(suggested: str) -> str | None:
    current = read_current_version()
    print(f"Current pubspec.yaml version: {current}")
    print(f"Suggested next version:       {suggested}")
    answer = input(
        "Apply suggested version? [y]es / [n]o-abort / "
        "or type a replacement version: "
    ).strip()

    if answer in ("", "y", "Y"):
        return suggested
    if answer in ("n", "N"):
        return None
    if not VERSION_RE.match(answer):
        log_error(f"Replacement version '{answer}' does not match x.y.z+a[-pre]")
        sys.exit(2)
    return answer


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="bump_version.py",
        description="Confirm and apply a pubspec.yaml version bump.",
    )
    parser.add_argument("--version", required=True, dest="suggested")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if not VERSION_RE.match(args.suggested):
        log_error(f"Suggested version '{args.suggested}' does not match x.y.z+a[-pre]")
        sys.exit(2)

    final = confirm_version(args.suggested)
    if final is None:
        log_info("Aborted, pubspec.yaml not changed.")
        sys.exit(1)

    write_version(final)
    log_info(f"Wrote version: {final}")


if __name__ == "__main__":
    main()
