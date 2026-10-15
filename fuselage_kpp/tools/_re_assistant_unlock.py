#!/usr/bin/env python3
"""Locate appCanUnlocker / unlock MAVLink emit path in JIYI221014."""
from __future__ import annotations

import re
import struct
from pathlib import Path


def main() -> int:
    exe = next(Path(__file__).resolve().parents[2].rglob("JIYI221014.exe"))
    data = exe.read_bytes()

    for needle in [
        b"appCanUnlocker",
        b"signal_appCanUnlocker",
        b"CanUnlock",
        b"canUnlock",
        b"Unlocker",
        b"unlocker",
        b"sendUnlock",
        b"doUnlock",
        b"setUnlock",
    ]:
        idxs = [m.start() for m in re.finditer(re.escape(needle), data)]
        print(needle.decode(), "count", len(idxs), "at", idxs[:10])
        for i in idxs[:3]:
            chunk = data[max(0, i - 80) : i + 120]
            ascii_bits = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
            print(" ", ascii_bits)

    # Nearby msgid immediates as bytes after string refs are hard; search for
    # COMMAND_LONG encode patterns: push 400 then call send.
    # Look for sequences: B8 90 01 00 00 (mov eax,400) or 68 90 01 00 00 (push 400)
    for pat, name in [
        (rb"\xB8\x90\x01\x00\x00", "mov_eax_400"),
        (rb"\x68\x90\x01\x00\x00", "push_400"),
        (rb"\x41\xB8\x90\x01\x00\x00", "mov_r8d_400"),
        (rb"\xC7.\x90\x01\x00\x00", "mov_mem_400"),
    ]:
        sites = [m.start() for m in re.finditer(pat, data)]
        print(name, len(sites), sites[:15])

    # Proprietary command candidates: look for msgid constants near Unlocker string
    unlock = data.find(b"appCanUnlocker")
    if unlock > 0:
        region = data[unlock : unlock + 400]
        # print printable runs
        runs = re.findall(rb"[\x20-\x7e]{6,}", region)
        print("strings near appCanUnlocker:")
        for r in runs[:40]:
            print(" ", r.decode())

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
