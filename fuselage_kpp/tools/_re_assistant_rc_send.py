#!/usr/bin/env python3
"""Inspect sendMavRcChValue and nearby msgid usage in JIYI221014."""
from __future__ import annotations

import re
from pathlib import Path


def main() -> int:
    exe = next(Path(__file__).resolve().parents[2].rglob("JIYI221014.exe"))
    data = exe.read_bytes()

    for needle in [
        b"sendMavRcChValue",
        b"sendMavRc2ChValue",
        b"signal_sendMavRcChValue",
        b"displayRc9to16Value",
        b"sendMav",
    ]:
        idxs = [m.start() for m in re.finditer(re.escape(needle), data)]
        print(needle.decode(errors="replace"), len(idxs))
        for i in idxs[:4]:
            chunk = data[max(0, i - 100) : i + 160]
            print(" ", "".join(chr(b) if 32 <= b < 127 else "." for b in chunk))

    # CRC extras table already found — msgid 70 RC_CHANNELS_OVERRIDE is 124 in
    # common.xml. Check table@796032 index 70.
    i = 796032
    print("crc table msgid 70", data[i + 70], "69", data[i + 69], "75", data[i + 75], "76", data[i + 76])

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
