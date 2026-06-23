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
"""Run wiki steps 4-6: fastlane, Apple platform, and Flatpak/Flathub
metadata generation for a release.

Entry points: scripts/release_postgen.sh, scripts/release_postgen.cmd.
This is the single place that knows: Apple notes are stable-only, and
Flatpak generation has no Windows port.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

IS_WINDOWS = os.name == "nt"


def resolve_repo_root() -> Path:
    script_path = Path(__file__).resolve()
    for parent in script_path.parents:
        if (parent / "pubspec.yaml").is_file() and (parent / ".git").exists():
            return parent
    raise RuntimeError(
        f"Failed to resolve repository root from script path: {script_path}"
    )


REPO_ROOT = resolve_repo_root()
SCRIPTS_DIR = REPO_ROOT / "scripts"


def log_info(message: str) -> None:
    print(f"[INFO] {message}")


def run_script(name: str) -> None:
    script = SCRIPTS_DIR / (f"{name}.cmd" if IS_WINDOWS else f"{name}.sh")
    if not script.is_file():
        log_info(f"Script not found, skipping: {script}")
        sys.exit(1)
    log_info(f"Running {script.name}...")
    result = subprocess.run([str(script)], cwd=REPO_ROOT)
    if result.returncode != 0:
        sys.exit(result.returncode)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="release_postgen.py",
        description="Run fastlane/Apple/Flatpak metadata generation for a release.",
    )
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--release", action="store_true")
    mode.add_argument("--pre", action="store_true")
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    log_info("[1/3] Fastlane changelogs (Android)...")
    run_script("gen_changelogs")

    if args.release:
        log_info("[2/3] Apple platform release notes (stable)...")
        run_script("gen_changelogs_darwin")
    else:
        log_info("[2/3] Skipping Apple platform release notes (pre/beta release).")

    log_info("[3/3] Flatpak/Flathub metainfo...")
    if IS_WINDOWS:
        log_info(
            "Skipping: gen_flatpak_info.sh has no Windows port (depends on "
            "xmlstarlet/flatpak tooling). Run it on macOS/Linux, or edit the "
            "metainfo files manually per the wiki."
        )
    else:
        run_script("gen_flatpak_info")

    log_info(
        "Done. Review changes under fastlane/, ios/macos fastlane, "
        "configs/flatpak_builder/, flatpak/ before committing."
    )


if __name__ == "__main__":
    main()
