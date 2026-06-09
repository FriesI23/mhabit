#!/usr/bin/env python3
"""Sync project rules to AI tool config files."""

from __future__ import annotations

import argparse
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


def log_info(message: str) -> None:
    print(f"[INFO] {message}")


def log_success(message: str) -> None:
    print(f"[SUCCESS] {message}")


def log_error(message: str) -> None:
    print(f"[ERROR] {message}")


def repo_globs() -> list[str]:
    # Keep all targeting repo-local. Do not encode workspace-level paths.
    return ["**/*"]


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


def install(rules_file: Path) -> None:
    check_rules_exists(rules_file)
    log_info("Starting rules installation...")

    rules_text = rules_file.read_text(encoding="utf-8")
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