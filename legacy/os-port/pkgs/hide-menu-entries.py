#!/usr/bin/env python3
"""Hide Omarchy menu ids, including when an entry spans more than one line.

Upstream menu rows are JSONC object keys. The value is usually a one-line
object, but a row may be wrapped. Matching is on the id key. The whole JSON
value is then removed, so a line-oriented delete cannot leave the body (and
its action) behind.

`check` fails if any id is still present as a key. The package build runs it
on the installed menu, and CI runs the same check on the built menu output.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


def key_pattern(menu_id: str) -> re.Pattern[str]:
    return re.compile(r'^[ \t]*"' + re.escape(menu_id) + r'"[ \t]*:', re.M)


def skip_ws_comments(text: str, i: int) -> int:
    n = len(text)
    while i < n:
        if text[i] in " \t\r\n":
            i += 1
            continue
        if text.startswith("//", i):
            nl = text.find("\n", i)
            i = n if nl < 0 else nl + 1
            continue
        break
    return i


def finish_entry(text: str, i: int) -> int:
    """i points just after the value's closing brace."""
    n = len(text)
    while i < n and text[i] in " \t":
        i += 1
    if i < n and text[i] == ",":
        i += 1
        while i < n and text[i] in " \t":
            i += 1
    if text.startswith("//", i):
        nl = text.find("\n", i)
        return n if nl < 0 else nl + 1
    if i < n and text[i] == "\n":
        return i + 1
    return i


def consume_value(text: str, i: int) -> int:
    """Consume a JSON object value starting at i. Returns the index after it."""
    n = len(text)
    i = skip_ws_comments(text, i)
    if i >= n or text[i] != "{":
        raise SystemExit(
            "omarchy-menu.jsonc: hidden menu entry is not a JSON object "
            f"(at offset {i})"
        )
    depth = 0
    in_str = False
    esc = False
    while i < n:
        c = text[i]
        if in_str:
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            i += 1
            continue
        if text.startswith("//", i):
            nl = text.find("\n", i)
            i = n if nl < 0 else nl + 1
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return finish_entry(text, i + 1)
        i += 1
    raise SystemExit("omarchy-menu.jsonc: unclosed hidden menu entry")


def still_present(text: str, menu_id: str) -> bool:
    return key_pattern(menu_id).search(text) is not None


def hide(text: str, ids: list[str]) -> str:
    for menu_id in ids:
        pat = key_pattern(menu_id)
        if pat.search(text) is None:
            raise SystemExit(
                "omarchy-menu.jsonc: expected entry missing (stale patch): "
                + menu_id
            )
        while True:
            match = pat.search(text)
            if match is None:
                break
            end = consume_value(text, match.end())
            text = text[: match.start()] + text[end:]
        if pat.search(text) is not None:
            raise SystemExit(
                "omarchy-menu.jsonc: hidden menu id still present: " + menu_id
            )
    return text


def check(text: str, ids: list[str]) -> None:
    found = [menu_id for menu_id in ids if still_present(text, menu_id)]
    if found:
        for menu_id in found:
            print(
                "omarchy-menu.jsonc: hidden menu id still present: " + menu_id,
                file=sys.stderr,
            )
        raise SystemExit(1)


def main(argv: list[str]) -> None:
    if len(argv) < 4 or argv[1] not in ("hide", "check"):
        raise SystemExit(
            "usage: hide-menu-entries.py hide|check MENU id [id ...]"
        )
    mode, path, *ids = argv[1:]
    file = Path(path)
    text = file.read_text()
    if mode == "check":
        check(text, ids)
        return
    updated = hide(text, ids)
    check(updated, ids)
    file.write_text(updated)


if __name__ == "__main__":
    main(sys.argv)
