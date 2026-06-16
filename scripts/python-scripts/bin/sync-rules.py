#!/usr/bin/env python3
"""Sync project rules to AI tool config files."""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path


def resolve_repo_root() -> Path:
    script_path = Path(__file__).resolve()
    for parent in script_path.parents:
        if (parent / "pubspec.yaml").is_file() and (parent / ".git").exists():
            return parent
    raise RuntimeError(
        f"Failed to resolve repository root from script path: {script_path}"
    )


REPO_ROOT = resolve_repo_root()
DEFAULT_RULES_FILE = REPO_ROOT / "docs/rules/rules.md"
CLAUDE_FILE = REPO_ROOT / "CLAUDE.md"
COPILOT_FILE = REPO_ROOT / ".github/copilot-instructions.md"
CONTINUE_FILE = REPO_ROOT / ".continue/rules/main.md"
CURSOR_FILE = REPO_ROOT / ".cursor/rules/main.mdc"

IGNORE_LIST = [
    ".continue/",
    ".cursor/",
    ".github/copilot-instructions.md",
    "CLAUDE.md",
]

# ---------------------------------------------------------------------------
# Per-tool output templates
#
# Each template is intentionally self-contained and readable on its own.
# Variables: {rel} = relative path from the output file to the rules file,
#            {name} = filename of the rules file (e.g. "rules.md").
# ---------------------------------------------------------------------------

CLAUDE_TEMPLATE = """\
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

See [{name}]({rel}) for the full rule set: architecture decisions, workflow
commands, provider patterns, Dart style requirements, and generated-code
conventions.
"""

COPILOT_TEMPLATE = """\
# Copilot Instructions

This file provides context for GitHub Copilot in the mhabit repository.

See [{name}]({rel}) for the full rule set: architecture decisions, workflow
commands, provider patterns, Dart style requirements, and generated-code
conventions.
"""

CONTINUE_TEMPLATE = """\
---
name: Project Rules
description: Rules for the mhabit repository only
alwaysApply: true
globs:
  - "**/*"
---

See [{name}]({rel}) for the full rule set: architecture decisions, workflow
commands, provider patterns, Dart style requirements, and generated-code
conventions.
"""

CURSOR_TEMPLATE = """\
---
description: Rules for the mhabit repository only
alwaysApply: true
globs:
  - "**/*"
---

See [{name}]({rel}) for the full rule set: architecture decisions, workflow
commands, provider patterns, Dart style requirements, and generated-code
conventions.
"""

# ---------------------------------------------------------------------------


def log_info(message: str) -> None:
    print(f"[INFO] {message}")


def log_success(message: str) -> None:
    print(f"[SUCCESS] {message}")


def log_error(message: str) -> None:
    print(f"[ERROR] {message}")


def check_rules_exists(rules_file: Path) -> None:
    if not rules_file.is_file():
        log_error(f"Rules file not found: {rules_file}")
        sys.exit(1)


def ensure_git_exclude_path() -> Path:
    git_exclude_dir = REPO_ROOT / ".git/info"
    git_exclude = git_exclude_dir / "exclude"

    if not git_exclude_dir.is_dir():
        log_error(f"Git metadata directory not found: {git_exclude_dir}")
        sys.exit(1)

    git_exclude.touch(exist_ok=True)
    return git_exclude


def read_lines(path: Path) -> list[str]:
    if not path.exists():
        return []
    return path.read_text(encoding="utf-8").splitlines()


def write_lines(path: Path, lines: list[str]) -> None:
    content = "\n".join(lines)
    if content:
        content += "\n"
    path.write_text(content, encoding="utf-8")


def update_git_exclude(action: str, pattern: str) -> None:
    git_exclude = ensure_git_exclude_path()
    lines = read_lines(git_exclude)

    if action == "add":
        if pattern not in lines:
            lines.append(pattern)
            write_lines(git_exclude, lines)
            log_info(f"Added {pattern} to {git_exclude}")
        else:
            log_info(f"{pattern} already in {git_exclude}")
        return

    if action == "remove":
        if pattern in lines:
            filtered = [line for line in lines if line != pattern]
            write_lines(git_exclude, filtered)
            log_info(f"Removed {pattern} from {git_exclude}")
        else:
            log_info(f"{pattern} not in {git_exclude}")


def _rel(from_file: Path, to_file: Path) -> str:
    """Relative path from from_file's directory to to_file, using forward slashes."""
    return Path(os.path.relpath(to_file, from_file.parent)).as_posix()


def install(rules_file: Path) -> None:
    check_rules_exists(rules_file)
    log_info("Starting rules installation...")

    vars_ = {"name": rules_file.name, "rel": _rel(CLAUDE_FILE, rules_file)}
    CLAUDE_FILE.write_text(CLAUDE_TEMPLATE.format(**vars_), encoding="utf-8")
    log_info(f"Created reference at {CLAUDE_FILE}")

    vars_ = {"name": rules_file.name, "rel": _rel(COPILOT_FILE, rules_file)}
    COPILOT_FILE.parent.mkdir(parents=True, exist_ok=True)
    COPILOT_FILE.write_text(COPILOT_TEMPLATE.format(**vars_), encoding="utf-8")
    log_info(f"Created reference at {COPILOT_FILE}")

    vars_ = {"name": rules_file.name, "rel": _rel(CONTINUE_FILE, rules_file)}
    CONTINUE_FILE.parent.mkdir(parents=True, exist_ok=True)
    CONTINUE_FILE.write_text(CONTINUE_TEMPLATE.format(**vars_), encoding="utf-8")
    log_info(f"Created reference at {CONTINUE_FILE}")

    vars_ = {"name": rules_file.name, "rel": _rel(CURSOR_FILE, rules_file)}
    CURSOR_FILE.parent.mkdir(parents=True, exist_ok=True)
    CURSOR_FILE.write_text(CURSOR_TEMPLATE.format(**vars_), encoding="utf-8")
    log_info(f"Created reference at {CURSOR_FILE}")

    for pattern in IGNORE_LIST:
        update_git_exclude("add", pattern)

    log_success("Rules installation complete!")


def uninstall() -> None:
    log_info("Starting rules uninstallation...")

    for path in [CLAUDE_FILE, COPILOT_FILE, CONTINUE_FILE, CURSOR_FILE]:
        path.unlink(missing_ok=True)
    log_info("Removed AI config files")

    for path in [
        REPO_ROOT / ".continue/rules",
        REPO_ROOT / ".continue",
        REPO_ROOT / ".cursor/rules",
        REPO_ROOT / ".cursor",
    ]:
        try:
            path.rmdir()
        except OSError:
            pass

    for pattern in IGNORE_LIST:
        update_git_exclude("remove", pattern)

    log_success("Rules uninstallation complete!")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="sync-rules.py",
        description="Sync rules file to AI tool config files.",
    )
    parser.add_argument("action", choices=["install", "uninstall"])
    parser.add_argument(
        "--rules-file",
        default=str(DEFAULT_RULES_FILE),
        help="Path to source rules file (used by install action)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    rules_file = Path(args.rules_file)
    if not rules_file.is_absolute():
        rules_file = (REPO_ROOT / rules_file).resolve()
    if args.action == "install":
        install(rules_file)
        return
    uninstall()


if __name__ == "__main__":
    main()
