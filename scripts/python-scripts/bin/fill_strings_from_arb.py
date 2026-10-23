# Copyright 2026 Fries_I23
# Licensed under the Apache License, Version 2.0.

"""Fill missing Apple .strings entries from one ARB, without replacing translations."""

import argparse
import codecs
import json
import logging
import os
import re
import stat
import sys
import tempfile
from pathlib import Path

_logger = logging.getLogger(__name__)

_EMPTY_TABLE_COMMENT = "/* Localized strings. Values may be maintained manually. */"
_BARE_KEY = re.compile(r"[A-Za-z0-9_$./:-]+")
_BARE_OUTPUT_KEY = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
_HEX = re.compile(r"[0-9a-fA-F]{4}")


def _unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"Duplicate JSON key: {key}")
        result[key] = value
    return result


def _read_json(path):
    with path.open("r", encoding="utf-8-sig") as stream:
        result = json.load(stream, object_pairs_hook=_unique_object)
    if not isinstance(result, dict):
        raise ValueError(f"Expected a JSON object: {path}")
    return result


def _read_refs(path):
    references = _read_json(path)
    targets = set()
    result = {}
    for source, entry in references.items():
        if not source or source.startswith("@"):
            raise ValueError(f"Expected an ARB message key, got: {source!r}")
        if not isinstance(entry, dict) or set(entry) != {"strings"}:
            raise ValueError(f"Expected {{strings: {{key: ...}}}} for {source}")
        strings = entry["strings"]
        if not isinstance(strings, dict) or set(strings) != {"key"}:
            raise ValueError(f"Expected {{key: ...}} for {source}.strings")
        target = strings["key"]
        if not isinstance(target, str) or not target:
            raise ValueError(f"Expected a nonempty strings key for {source}")
        if target in targets:
            raise ValueError(f"Duplicate target strings key: {target}")
        targets.add(target)
        result[source] = target
    return result


def _skip_spacing(text, index):
    while index < len(text):
        if text[index].isspace():
            index += 1
        elif text.startswith("//", index):
            index += 2
            while index < len(text) and text[index] not in "\r\n":
                index += 1
        elif text.startswith("/*", index):
            end = text.find("*/", index + 2)
            if end == -1:
                raise ValueError(f"Unterminated .strings comment at offset {index}")
            index = end + 2
        else:
            break
    return index


def _quoted(text, index):
    start = index
    index += 1
    value = []
    escapes = {
        '"': '"',
        "\\": "\\",
        "n": "\n",
        "r": "\r",
        "t": "\t",
        "b": "\b",
        "f": "\f",
        "a": "\a",
        "v": "\v",
    }
    while index < len(text):
        character = text[index]
        index += 1
        if character == '"':
            # Escaped UTF-16 surrogate pairs represent one Unicode character.
            decoded = "".join(value).encode("utf-16-le", "surrogatepass")
            return decoded.decode("utf-16-le"), index
        if character == "\\":
            if index >= len(text):
                break
            escape = text[index]
            index += 1
            if escape in escapes:
                value.append(escapes[escape])
            elif escape in "Uu":
                digits = text[index : index + 4]
                if not _HEX.fullmatch(digits):
                    raise ValueError(
                        f"Invalid .strings Unicode escape at offset {index - 2}"
                    )
                value.append(chr(int(digits, 16)))
                index += 4
            elif escape in "01234567":
                digits = escape
                while (
                    len(digits) < 3 and index < len(text) and text[index] in "01234567"
                ):
                    digits += text[index]
                    index += 1
                value.append(chr(int(digits, 8)))
            elif escape in "\r\n":
                if escape == "\r" and index < len(text) and text[index] == "\n":
                    index += 1
            else:
                raise ValueError(
                    f"Unsupported .strings escape \\{escape} at offset {index - 2}"
                )
        elif character == "\0":
            raise ValueError(f"Unexpected NUL in .strings at offset {index - 1}")
        else:
            value.append(character)
    raise ValueError(f"Unterminated .strings quoted text at offset {start}")


def parse_strings(text):
    """Read quoted/bare keys, quoted values and comments without rewriting text."""
    result = {}
    index = _skip_spacing(text, 0)
    while index < len(text):
        if text[index] == '"':
            key, index = _quoted(text, index)
        else:
            match = _BARE_KEY.match(text, index)
            if match is None:
                raise ValueError(f"Expected a .strings key at offset {index}")
            end = match.end()
            for offset in range(index, end):
                if text.startswith(("/*", "//"), offset):
                    end = offset
                    break
            if end == index:
                raise ValueError(f"Expected a .strings key at offset {index}")
            key = text[index:end]
            index = end
        if key in result:
            raise ValueError(f"Duplicate .strings key: {key}")
        index = _skip_spacing(text, index)
        if index >= len(text) or text[index] != "=":
            raise ValueError(f"Expected '=' after .strings key {key!r}")
        index = _skip_spacing(text, index + 1)
        if index >= len(text) or text[index] != '"':
            raise ValueError(f"Expected a quoted .strings value for {key!r}")
        value, index = _quoted(text, index)
        index = _skip_spacing(text, index)
        if index >= len(text) or text[index] != ";":
            raise ValueError(f"Expected ';' after .strings key {key!r}")
        result[key] = value
        index = _skip_spacing(text, index + 1)
    return result


def _decode_strings(data):
    for bom, encoding in (
        (codecs.BOM_UTF8, "utf-8"),
        (codecs.BOM_UTF16_LE, "utf-16-le"),
        (codecs.BOM_UTF16_BE, "utf-16-be"),
    ):
        if data.startswith(bom):
            return data[len(bom) :].decode(encoding), encoding, bom
    return data.decode("utf-8"), "utf-8", b""


def _escape_strings(value):
    result = []
    escapes = {'"': '\\"', "\\": "\\\\", "\n": "\\n", "\r": "\\r", "\t": "\\t"}
    for character in value:
        if character in escapes:
            result.append(escapes[character])
        elif ord(character) < 0x20 or ord(character) == 0x7F:
            result.append(f"\\U{ord(character):04X}")
        else:
            result.append(character)
    return "".join(result)


def _plain_text(arb, source):
    text = arb[source]
    metadata = arb.get("@" + source, {})
    if not isinstance(text, str):
        raise ValueError(f"ARB message {source} must be a string")
    if not isinstance(metadata, dict):
        raise ValueError(f"ARB metadata for {source} must be an object")
    if metadata.get("placeholders") or "{" in text or "}" in text:
        raise ValueError(
            f"ARB message {source} must be plain text without ICU or placeholders"
        )
    # Reject lone surrogates before any output or temporary files are written.
    text.encode("utf-8")
    return text


def _atomic_write(path, data, original):
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o644
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            dir=path.parent, prefix="." + path.name + ".", delete=False
        ) as stream:
            temporary = stream.name
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, mode)
        # Preserve edits made after the initial read instead of replacing them.
        current = path.read_bytes() if path.exists() else None
        if current != original:
            raise ValueError(f"Target changed while filling strings: {path}")
        os.replace(temporary, path)
        temporary = None
    finally:
        if temporary is not None:
            os.unlink(temporary)


def fill_strings(
    input_path, output_path, refs_path, *, check=False, require_sources=False
):
    """Return whether filling is needed; check mode never creates or edits files."""
    references = _read_refs(refs_path)
    arb = _read_json(input_path)
    original = output_path.read_bytes() if output_path.exists() else None
    text, encoding, bom = _decode_strings(original or b"")
    existing = parse_strings(text)
    additions = []
    for source, target in references.items():
        if source not in arb:
            if require_sources:
                raise ValueError(f"Required ARB message is missing: {source}")
            continue
        value = _plain_text(arb, source)
        if target not in existing:
            key = (
                target
                if _BARE_OUTPUT_KEY.fullmatch(target)
                else f'"{_escape_strings(target)}"'
            )
            additions.append(f'{key} = "{_escape_strings(value)}";')
    newline_match = re.search(r"\r\n|\r|\n", text)
    newline = newline_match[0] if newline_match else "\n"
    appended = []
    if not text.strip():
        appended.append(_EMPTY_TABLE_COMMENT)
    appended.extend(additions)
    suffix = ""
    if appended:
        if text and not text.endswith(("\r", "\n")):
            suffix += newline
        suffix += newline.join(appended) + newline
    updated = bom + text.encode(encoding) + suffix.encode(encoding)
    changed = original is None or updated != original
    if changed and not check:
        _atomic_write(output_path, updated, original)
    return changed


def main(arguments=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "-i", "--input", required=True, type=Path, help="One source ARB file"
    )
    parser.add_argument(
        "-o", "--output", required=True, type=Path, help="Target .strings file"
    )
    parser.add_argument(
        "--refs", required=True, type=Path, help="ARB-key to strings-key JSON mapping"
    )
    parser.add_argument(
        "--check", action="store_true", help="Report pending additions without writing"
    )
    parser.add_argument(
        "--require-sources",
        action="store_true",
        help="Fail if a configured ARB key is absent",
    )
    args = parser.parse_args(arguments)
    try:
        changed = fill_strings(
            args.input,
            args.output,
            args.refs,
            check=args.check,
            require_sources=args.require_sources,
        )
    except (OSError, ValueError, UnicodeError) as error:
        _logger.error("%s: %s", args.output, error)
        return 2
    if args.check and changed:
        status = "Would change"
    else:
        status = "Changed" if changed else "Unchanged"
    _logger.info("%s: %s", status, Path(*args.output.parts[-2:]))
    return 1 if args.check and changed else 0


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    sys.exit(main())
