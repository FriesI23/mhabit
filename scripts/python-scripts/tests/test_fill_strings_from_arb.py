# Copyright 2026 Fries_I23
# Licensed under the Apache License, Version 2.0.

import codecs
import importlib.util
import json
import os
import shlex
import shutil
import stat
import subprocess
import sys
from functools import partial
from pathlib import Path
from types import SimpleNamespace

import pytest


PROJECT = Path(__file__).resolve().parents[1]
SCRIPT = PROJECT / "bin" / "fill_strings_from_arb.py"
WRAPPER = PROJECT.parent / "sync_native_l10n.sh"
SPEC = importlib.util.spec_from_file_location("fill_strings_from_arb", SCRIPT)
TOOL = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(TOOL)


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")


def write_output(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


@pytest.fixture
def files(tmp_path):
    paths = SimpleNamespace(
        arb=tmp_path / "input.arb",
        refs=tmp_path / "refs.json",
        output=tmp_path / "nested" / "Localizable.strings",
    )
    write_json(paths.arb, {"message": "Translated"})
    write_json(paths.refs, {"message": {"strings": {"key": "Native key"}}})
    return paths


@pytest.fixture
def fill(files):
    return partial(TOOL.fill_strings, files.arb, files.output, files.refs)


@pytest.fixture
def cli(files):
    def run(*options):
        return subprocess.run(
            [
                sys.executable,
                str(SCRIPT),
                "-i", str(files.arb),
                "-o", str(files.output),
                "--refs", str(files.refs),
                *options,
            ],
            capture_output=True,
            text=True,
            check=False,
        )

    return run


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        (
            '// "ignored" = "fake";\n/* comment */\nName = "Text";\n'
            '"Quoted key" /*x*/ = "Value";',
            {"Name": "Text", "Quoted key": "Value"},
        ),
        ('Name/* comment */="Value";', {"Name": "Value"}),
        (
            r'"say\"hi" = "a\\b\n\r\t\b\f\a\v";',
            {'say"hi': "a\\b\n\r\t\b\f\a\v"},
        ),
        (r'"\U0041" = "\101\UD83D\UDE00";', {"A": "A😀"}),
        ('"x" = "first\nsecond\\\nthird";', {"x": "first\nsecondthird"}),
        ("", {}),
        (" \r\n", {}),
        ("// comment", {}),
        ("/* comment */", {}),
    ],
)
def test_parse_strings(text, expected):
    assert TOOL.parse_strings(text) == expected


def test_duplicate_decoded_keys_fail():
    with pytest.raises(ValueError, match=r"Duplicate \.strings key"):
        TOOL.parse_strings(r'"A" = "one"; "\U0041" = "two";')


@pytest.mark.parametrize(
    "text",
    [
        "/* unclosed",
        '"key" = "unclosed',
        '"key" "value";',
        '"key" = "value"',
        '"key" = unquoted;',
        r'"x" = "\q";',
        r'"x" = "\Uabc";',
        '"x" = "\0";',
        '!bad = "value";',
    ],
)
def test_malformed_text_fails(text):
    with pytest.raises(ValueError):
        TOOL.parse_strings(text)


def test_append_preserves_manual_values_and_unmapped_text(files, fill):
    original = b'/* Keep my comments. */\n"Manual" = "Different";\n'
    write_output(files.output, original)
    assert fill()
    assert files.output.read_bytes().startswith(original)
    assert TOOL.parse_strings(files.output.read_text(encoding="utf-8")) == {
        "Manual": "Different", "Native key": "Translated",
    }


@pytest.mark.parametrize("value", ["Manual translation", ""])
def test_existing_values_are_never_overwritten(files, fill, value):
    original = f'"Native key" = "{value}";\n'.encode()
    write_output(files.output, original)
    assert not fill()
    assert files.output.read_bytes() == original


@pytest.mark.parametrize("key", ["HomeWidgetToday", "ordinaryName", "snake_case", "_internal", "a1"])
def test_simple_ascii_identifiers_are_appended_as_bare_keys(files, fill, key):
    write_json(files.refs, {"message": {"strings": {"key": key}}})
    assert fill(check=True)
    assert not files.output.parent.exists()
    assert fill()
    text = files.output.read_text(encoding="utf-8")
    assert text.endswith(f'{key} = "Translated";\n')
    assert TOOL.parse_strings(text) == {key: "Translated"}
    before = files.output.stat().st_mtime_ns
    assert not fill(check=True)
    assert files.output.stat().st_mtime_ns == before


@pytest.mark.parametrize(
    "key",
    ["1Name", "with space", "Dot.Key", "with-dash", "with/slash", "a//comment",
     "a/*comment*/", "name:", "$Dollar", "标识", "Name😀", 'quote"', "back\\slash", "line\nbreak"],
)
def test_complex_keys_remain_safely_quoted(files, fill, key):
    write_json(files.refs, {"message": {"strings": {"key": key}}})
    assert fill()
    text = files.output.read_text(encoding="utf-8")
    entry = text.splitlines()[-1]
    assert entry.startswith('"')
    assert entry.endswith('" = "Translated";')
    assert TOOL.parse_strings(text) == {key: "Translated"}


def test_existing_quoted_identifier_is_not_rewritten_or_duplicated(files, fill):
    original = b'/* Manual formatting. */\n"HomeWidgetToday"="Manual value";\n'
    write_output(files.output, original)
    write_json(files.refs, {"message": {"strings": {"key": "HomeWidgetToday"}}})
    before = files.output.stat().st_mtime_ns
    assert not fill(check=True)
    assert not fill()
    assert files.output.read_bytes() == original
    assert files.output.stat().st_mtime_ns == before

    write_json(files.arb, {"message": "Translated", "other": "Another"})
    write_json(files.refs, {
        "message": {"strings": {"key": "HomeWidgetToday"}},
        "other": {"strings": {"key": "OtherName"}},
    })
    assert fill()
    assert files.output.read_bytes() == original + b'OtherName = "Another";\n'
    assert TOOL.parse_strings(files.output.read_text(encoding="utf-8")) == {
        "HomeWidgetToday": "Manual value", "OtherName": "Another",
    }


def test_idempotence_does_not_rewrite_file(files, fill):
    assert fill()
    before = files.output.stat().st_mtime_ns
    content = files.output.read_bytes()
    assert not fill()
    assert files.output.stat().st_mtime_ns == before
    assert files.output.read_bytes() == content


def test_current_arb_only_without_english_or_script_fallback(files, fill):
    write_json(files.arb, {"@@locale": "zh_Hant"})
    assert fill()
    assert TOOL.parse_strings(files.output.read_text(encoding="utf-8")) == {}
    assert "/*" in files.output.read_text(encoding="utf-8")
    assert not fill(check=True)


def test_check_missing_output_does_not_create_parent(files, fill):
    write_json(files.arb, {})
    assert fill(check=True)
    assert not files.output.parent.exists()


def test_check_pending_append_never_changes_target(files, fill):
    original = b'"Other" = "Manual";'
    write_output(files.output, original)
    before = files.output.stat().st_mtime_ns
    assert fill(check=True)
    assert files.output.read_bytes() == original
    assert files.output.stat().st_mtime_ns == before


def test_require_sources_fails_even_when_native_key_exists(files, fill):
    original = b'"Native key" = "Manual";'
    write_output(files.output, original)
    write_json(files.arb, {})
    with pytest.raises(ValueError, match="Required ARB message"):
        fill(require_sources=True)
    assert files.output.read_bytes() == original


@pytest.mark.parametrize(
    ("encoding", "bom", "newline"),
    [
        ("utf-8", b"", "\n"),
        ("utf-8", codecs.BOM_UTF8, "\r\n"),
        ("utf-16-le", codecs.BOM_UTF16_LE, "\r\n"),
        ("utf-16-be", codecs.BOM_UTF16_BE, "\r"),
    ],
)
@pytest.mark.parametrize(
    ("key", "rendered_key"),
    [("Native key", '"Native key"'), ("HomeWidgetToday", "HomeWidgetToday")],
)
def test_boms_endianness_and_line_endings_are_preserved(
    files, fill, encoding, bom, newline, key, rendered_key
):
    write_json(files.refs, {"message": {"strings": {"key": key}}})
    original = bom + ('"原有" = "手工内容";' + newline).encode(encoding)
    write_output(files.output, original)
    assert fill(check=True)
    assert files.output.read_bytes() == original
    assert fill()
    assert files.output.read_bytes() == original + (
        f'{rendered_key} = "Translated";' + newline
    ).encode(encoding)
    assert not fill(check=True)


def test_separator_after_final_line_comment(files, fill):
    original = b'"Old" = "old";\r\n// Keep this trailing comment'
    write_output(files.output, original)
    fill()
    assert files.output.read_bytes() == original + (
        b'\r\n"Native key" = "Translated";\r\n'
    )


def test_empty_table_gets_valid_comment(files, fill):
    write_json(files.arb, {})
    write_output(files.output, codecs.BOM_UTF8)
    assert fill()
    assert files.output.read_bytes().startswith(codecs.BOM_UTF8 + b"/*")
    assert not fill()


@pytest.mark.skipif(os.name == "nt", reason="POSIX file permissions")
def test_existing_permissions_are_preserved(files, fill):
    write_output(files.output, b'"Old" = "old";\n')
    files.output.chmod(0o640)
    fill()
    assert stat.S_IMODE(files.output.stat().st_mode) == 0o640


def test_whitespace_only_table_preserves_original_then_initializes(files, fill):
    write_json(files.arb, {})
    original = b" \r\n\t"
    write_output(files.output, original)
    assert fill()
    initialized = files.output.read_bytes()
    assert initialized.startswith(original)
    assert TOOL.parse_strings(initialized.decode()) == {}
    assert not fill()


def test_atomic_replace_error_preserves_target_and_removes_temporary(
    files, fill, monkeypatch
):
    original = b'"Old" = "old";\n'
    write_output(files.output, original)

    def reject_replace(*args):
        raise OSError("replace failed")

    monkeypatch.setattr(TOOL.os, "replace", reject_replace)
    with pytest.raises(OSError, match="replace failed"):
        fill()
    assert files.output.read_bytes() == original
    assert list(files.output.parent.iterdir()) == [files.output]


def test_concurrent_edit_is_preserved_instead_of_overwritten(
    files, fill, monkeypatch
):
    original = b'"Old" = "old";\n'
    updated = b'"Old" = "new manual edit";\n'
    write_output(files.output, original)

    def edit_while_preparing(*args):
        files.output.write_bytes(updated)

    monkeypatch.setattr(TOOL.os, "chmod", edit_while_preparing)
    with pytest.raises(ValueError, match="Target changed"):
        fill()
    assert files.output.read_bytes() == updated
    assert list(files.output.parent.iterdir()) == [files.output]


def test_escaping_source_and_target_text_roundtrips(files, fill):
    target = 'Quote " and slash \\ and \n'
    value = '译文 😀 " \\ \n\r\t\0'
    write_json(files.refs, {"message": {"strings": {"key": target}}})
    write_json(files.arb, {"message": value})
    fill()
    assert TOOL.parse_strings(files.output.read_text(encoding="utf-8")) == {target: value}


@pytest.mark.parametrize(
    "arb",
    [
        {"message": None},
        {"message": 7},
        {"message": "{count}"},
        {"message": "{count, plural, other {items}}"},
        {"message": "Text", "@message": {"placeholders": {"name": {}}}},
        {"message": "Text", "@message": []},
    ],
)
def test_invalid_source_or_icu_never_mutates_target(files, fill, arb):
    original = b'"Old" = "old";\n'
    write_output(files.output, original)
    write_json(files.arb, arb)
    with pytest.raises(ValueError):
        fill()
    assert files.output.read_bytes() == original
    assert list(files.output.parent.iterdir()) == [files.output]


@pytest.mark.parametrize(
    "refs",
    [
        [],
        {"message": "Native key"},
        {"message": {"strings": {}}},
        {"message": {"strings": {"key": ""}}},
        {"message": {"strings": {"key": "key", "value": "unsupported"}}},
        {"@message": {"strings": {"key": "key"}}},
        {"a": {"strings": {"key": "same"}}, "b": {"strings": {"key": "same"}}},
    ],
)
def test_invalid_configs_fail_before_creating_output(files, fill, refs):
    write_json(files.refs, refs)
    with pytest.raises(ValueError):
        fill()
    assert not files.output.parent.exists()


def test_duplicate_json_source_keys_fail(files, fill):
    files.refs.write_text(
        '{"message":{"strings":{"key":"a"}},"message":{"strings":{"key":"b"}}}'
    )
    with pytest.raises(ValueError, match="Duplicate JSON key"):
        fill()
    assert not files.output.parent.exists()


@pytest.mark.parametrize(
    "original",
    [b'"x" = "unclosed', b'"x" = "1"; x = "2";', b'\xffinvalid utf8'],
)
def test_malformed_target_and_unsupported_encoding_never_mutate(
    files, fill, original
):
    write_output(files.output, original)
    with pytest.raises((ValueError, UnicodeError)):
        fill()
    assert files.output.read_bytes() == original


def test_cli_exit_codes_for_check_fill_and_error(files, cli):
    assert cli("--check").returncode == 1
    assert not files.output.parent.exists()
    assert cli().returncode == 0
    assert cli("--check").returncode == 0
    write_json(files.arb, {})
    assert cli("--require-sources").returncode == 2
    assert cli("--unknown-option").returncode == 2


@pytest.fixture
def wrapper_repo(tmp_path, monkeypatch):
    if os.name == "nt":
        pytest.skip("POSIX wrapper; Windows wrapper is checked statically")
    repo = tmp_path / "repo with spaces"
    scripts = repo / "scripts"
    tool_dir = scripts / "python-scripts" / "bin"
    tool_dir.mkdir(parents=True)
    wrapper = scripts / WRAPPER.name
    shutil.copy2(WRAPPER, wrapper)
    shutil.copy2(SCRIPT, tool_dir / SCRIPT.name)
    arb_dir = repo / "assets" / "l10n"
    arb_dir.mkdir(parents=True)
    strings_dir = repo / "ios" / "HabitWidget" / "Extension"
    refs = repo / "configs" / "l10n_strings_refs.json"
    refs.parent.mkdir()
    write_json(refs, {"message": {"strings": {"key": "Stable key"}}})
    command_dir = tmp_path / "commands"
    command_dir.mkdir()
    environment_dir = tmp_path / "poetry environment"
    (environment_dir / "bin").mkdir(parents=True)
    (environment_dir / "bin" / "python").symlink_to(sys.executable)
    poetry = command_dir / "poetry"
    poetry.write_text(
        "#!/bin/sh\nprintf '%s\\n' " + shlex.quote(str(environment_dir)) + "\n"
    )
    poetry.chmod(0o755)
    monkeypatch.setenv("PATH", str(command_dir) + os.pathsep + os.environ.get("PATH", ""))

    def run(*options):
        # Caller cwd differs from the repository; paths come from the wrapper.
        return subprocess.run(
            ["bash", str(wrapper), *options],
            cwd=tmp_path,
            capture_output=True,
            text=True,
            check=False,
        )

    return SimpleNamespace(
        repo=repo,
        wrapper=wrapper,
        arb_dir=arb_dir,
        strings_dir=strings_dir,
        run=run,
    )


@pytest.fixture
def two_group_wrapper(wrapper_repo):
    other_arb_dir = wrapper_repo.repo / "assets" / "secondary l10n"
    other_arb_dir.mkdir()
    other_strings_dir = wrapper_repo.repo / "ios" / "Other" / "Extension"
    other_refs = wrapper_repo.repo / "configs" / "other_refs.json"
    write_json(other_refs, {"other_message": {"strings": {"key": "Other key"}}})
    write_json(wrapper_repo.arb_dir / "en.arb", {"message": "First translation"})
    write_json(other_arb_dir / "en.arb", {"other_message": "Second translation"})
    write_json(other_arb_dir / "zh_hant.arb", {"other_message": "第二組"})

    marker = "# End native table calls."
    script = wrapper_repo.wrapper.read_text(encoding="utf-8")
    assert script.count(marker) == 1
    wrapper_repo.wrapper.write_text(
        script.replace(
            marker,
            'fill_native_strings "$REPO_ROOT/assets/secondary l10n" '
            '"$REPO_ROOT/ios/Other/Extension" '
            '"$REPO_ROOT/configs/other_refs.json" "Settings.strings"\n' + marker,
        ),
        encoding="utf-8",
    )
    wrapper_repo.other_strings_dir = other_strings_dir
    return wrapper_repo


def test_wrapper_multiple_groups_check_fill_and_idempotence(two_group_wrapper):
    first = two_group_wrapper.strings_dir / "en.lproj" / "Localizable.strings"
    second = two_group_wrapper.other_strings_dir / "en.lproj" / "Settings.strings"
    traditional = (
        two_group_wrapper.other_strings_dir / "zh-Hant.lproj" / "Settings.strings"
    )
    pending = two_group_wrapper.run("--check")
    assert pending.returncode == 1
    # A pending first group must not prevent checking the second configuration.
    for path in (first, second, traditional):
        assert str(Path(path.parent.name) / path.name) in pending.stderr
    assert not two_group_wrapper.strings_dir.exists()
    assert not two_group_wrapper.other_strings_dir.exists()

    assert two_group_wrapper.run().returncode == 0
    assert TOOL.parse_strings(first.read_text(encoding="utf-8")) == {
        "Stable key": "First translation",
    }
    assert TOOL.parse_strings(second.read_text(encoding="utf-8")) == {
        "Other key": "Second translation",
    }
    assert TOOL.parse_strings(traditional.read_text(encoding="utf-8")) == {
        "Other key": "第二組",
    }
    assert not list(two_group_wrapper.other_strings_dir.glob("*/Localizable.strings"))
    before = {
        path: (path.read_bytes(), path.stat().st_mtime_ns)
        for path in (first, second, traditional)
    }
    assert two_group_wrapper.run("--check").returncode == 0
    assert two_group_wrapper.run().returncode == 0
    assert {
        path: (path.read_bytes(), path.stat().st_mtime_ns) for path in before
    } == before


@pytest.mark.parametrize("options", [(), ("--check",)])
def test_wrapper_later_group_error_is_propagated_without_replacing_it(
    two_group_wrapper, options
):
    first = two_group_wrapper.strings_dir / "en.lproj" / "Localizable.strings"
    invalid = two_group_wrapper.other_strings_dir / "en.lproj" / "Settings.strings"
    original = b'/* Keep this manual file. */\n"Other key" = "unclosed'
    write_output(invalid, original)
    before = invalid.stat().st_mtime_ns

    result = two_group_wrapper.run(*options)
    assert result.returncode == 2
    assert str(invalid) in result.stderr
    assert invalid.read_bytes() == original
    assert invalid.stat().st_mtime_ns == before
    assert set(two_group_wrapper.other_strings_dir.rglob("*")) == {
        invalid.parent, invalid,
    }
    if options:
        assert str(Path(first.parent.name) / first.name) in result.stderr
        assert not first.parent.exists()
    else:
        assert TOOL.parse_strings(first.read_text(encoding="utf-8")) == {
            "Stable key": "First translation",
        }


def test_wrapper_all_22_languages_and_check_idempotence(wrapper_repo):
    locales = "ar cs de en es eu fa fr he hu it ja nb nl pl pt ru tr uk vi zh zh_hant".split()
    for locale in locales:
        write_json(wrapper_repo.arb_dir / (locale + ".arb"), {"message": locale})
    assert wrapper_repo.run("--check").returncode == 1
    assert not wrapper_repo.strings_dir.exists()
    assert wrapper_repo.run().returncode == 0
    assert len(list(wrapper_repo.strings_dir.glob("*.lproj/Localizable.strings"))) == 22
    for locale in locales:
        native = {"zh": "zh-Hans", "zh_hant": "zh-Hant"}.get(locale, locale)
        target = wrapper_repo.strings_dir / (native + ".lproj") / "Localizable.strings"
        assert TOOL.parse_strings(target.read_text(encoding="utf-8")) == {"Stable key": locale}
    assert wrapper_repo.run("--check").returncode == 0


def test_wrapper_only_english_requires_sources(wrapper_repo):
    write_json(wrapper_repo.arb_dir / "en.arb", {"message": "English"})
    write_json(wrapper_repo.arb_dir / "fr.arb", {})
    assert wrapper_repo.run().returncode == 0
    french = wrapper_repo.strings_dir / "fr.lproj" / "Localizable.strings"
    assert TOOL.parse_strings(french.read_text(encoding="utf-8")) == {}
    english = wrapper_repo.strings_dir / "en.lproj" / "Localizable.strings"
    previous = english.read_bytes()
    write_json(wrapper_repo.arb_dir / "en.arb", {})
    assert wrapper_repo.run("--check").returncode == 2
    assert english.read_bytes() == previous


def test_wrapper_missing_arbs_returns_two(wrapper_repo):
    assert wrapper_repo.run().returncode == 2
    assert not wrapper_repo.strings_dir.exists()


@pytest.mark.parametrize(
    "options",
    [("--unknown",), ("--table", "Custom.strings"), ("--check", "--check")],
)
def test_wrapper_rejects_unsupported_options_without_writes(wrapper_repo, options):
    assert wrapper_repo.run(*options).returncode == 2
    assert not wrapper_repo.strings_dir.exists()


@pytest.mark.parametrize("option", ["--help", "-h"])
def test_wrapper_help_has_no_side_effects(wrapper_repo, option):
    result = wrapper_repo.run(option)
    assert result.returncode == 0
    assert "--check" in result.stdout
    assert not wrapper_repo.strings_dir.exists()
