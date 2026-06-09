#!/usr/bin/env python3
"""Sync project rules to AI tool config files."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


RULES_FILE = Path("docs/rules/rules.md")
CLAUDE_FILE = Path("CLAUDE.md")
COPILOT_FILE = Path(".github/copilot-instructions.md")
CONTINUE_FILE = Path(".continue/rules/main.md")
CURSOR_FILE = Path(".cursor/rules/main.mdc")

IGNORE_LIST = [
    ".continue/",
    ".cursor/",
    ".github/copilot-instructions.md",
    "CLAUDE.md",
]


def log_info(message: str) -> None:
    print(f"[INFO] {message}")


def log_success(message: str) -> None:
    print(f"[SUCCESS] {message}")


def log_error(message: str) -> None:
    print(f"[ERROR] {message}")


def repo_globs() -> list[str]:
    # Keep all targeting repo-local. Do not encode workspace-level paths.
    return ["**/*"]


def check_rules_exists() -> None:
    if not RULES_FILE.is_file():
        log_error(f"Rules file not found: {RULES_FILE}")
        sys.exit(1)


def ensure_git_exclude_path() -> Path:
    git_exclude_dir = Path(".git/info")
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


def build_frontmatter(*, name: str | None = None, description: str, globs: list[str]) -> str:
    lines = ["---"]
    if name:
        lines.append(f"name: {name}")
    lines.extend(
        [
            f"description: {description}",
            "alwaysApply: true",
            "globs:",
            *(f"  - {glob_item}" for glob_item in globs),
            "---",
            "",
        ]
    )
    return "\n".join(lines)


def install() -> None:
    check_rules_exists()
    log_info("Starting rules installation...")

    rules_text = RULES_FILE.read_text(encoding="utf-8")
    scoped_globs = repo_globs()

    CLAUDE_FILE.write_text(rules_text, encoding="utf-8")
    log_info(f"Copied rules to {CLAUDE_FILE}")

    COPILOT_FILE.parent.mkdir(parents=True, exist_ok=True)
    COPILOT_FILE.write_text(rules_text, encoding="utf-8")
    log_info(f"Copied rules to {COPILOT_FILE}")

    CONTINUE_FILE.parent.mkdir(parents=True, exist_ok=True)
    continue_header = build_frontmatter(
        name="Project Rules",
        description="Rules for the mhabit repository only",
        globs=scoped_globs,
    )
    CONTINUE_FILE.write_text(
        f"{continue_header}{rules_text}",
        encoding="utf-8",
    )
    log_info(f"Created {CONTINUE_FILE} with frontmatter")

    CURSOR_FILE.parent.mkdir(parents=True, exist_ok=True)
    cursor_header = build_frontmatter(
        description="Rules for the mhabit repository only",
        globs=scoped_globs,
    )
    CURSOR_FILE.write_text(
        f"{cursor_header}{rules_text}",
        encoding="utf-8",
    )
    log_info(f"Created {CURSOR_FILE} with frontmatter")

    for pattern in IGNORE_LIST:
        update_git_exclude("add", pattern)

    log_success("Rules installation complete!")


def uninstall() -> None:
    log_info("Starting rules uninstallation...")

    for path in [CLAUDE_FILE, COPILOT_FILE, CONTINUE_FILE, CURSOR_FILE]:
        path.unlink(missing_ok=True)
    log_info("Removed AI config files")

    for path in [Path(".continue/rules"), Path(".continue"), Path(".cursor/rules"), Path(".cursor")]:
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
        description="Sync docs/rules/rules.md to AI tool config files.",
    )
    parser.add_argument("action", choices=["install", "uninstall"])
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.action == "install":
        install()
        return
    uninstall()


if __name__ == "__main__":
    main()