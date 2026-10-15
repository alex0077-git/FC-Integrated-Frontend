#!/usr/bin/env python3
"""Locate how JIYI221014 parses GPS sats (displayGps1data route)."""
from __future__ import annotations

import re
import struct
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    exe = next(root.rglob("JIYI221014.exe"))
    data = exe.read_bytes()
    print("exe", exe, "size", len(data))

    for needle in (
        b"displayGps1data",
        b"signal_sendGps1Data",
        b"displayGps2data",
        b"signal_sendGps2Data",
        b"requestAllStreamDataSlot",
    ):
        idxs = [m.start() for m in re.finditer(re.escape(needle), data)]
        print(needle.decode(), idxs[:8])

    off = data.find(b"displayGps1data")
    print("meta context:", data[off - 40 : off + 100])

    for mid in (203, 206, 24, 124, 33, 25):
        pat = struct.pack("<I", mid)
        print(f"le32 {mid} count={data.count(pat)} first={data.find(pat)}")

    # x86 immediates for msgid 206 (0xCE)
    cands = [m.start() for m in re.finditer(rb"\xB8\xCE\x00\x00\x00|\x3D\xCE\x00\x00\x00", data)]
    print("mov/cmp eax,206 sites", len(cands), cands[:30])

    # Also look for 0xCB (203)
    cands203 = [m.start() for m in re.finditer(rb"\xB8\xCB\x00\x00\x00|\x3D\xCB\x00\x00\x00", data)]
    print("mov/cmp eax,203 sites", len(cands203), cands203[:30])

    for s in ["(信号好)", "(信号差)", "(no fix)", "(高精度)", "定位精度", "定位状态"]:
        b = s.encode("utf-8")
        print(repr(s), "at", data.find(b))

    # Dump bytes around each mov eax,206 — look for nearby payload index loads
    for i, pos in enumerate(cands[:15]):
        window = data[pos - 32 : pos + 64]
        print(f"\n--- site {i} @{pos:#x} ---")
        print(window.hex())
        # printable nearby
        asc = re.findall(rb"[\x20-\x7e]{4,}", data[max(0, pos - 200) : pos + 200])
        if asc:
            print("nearby ascii:", [a.decode() for a in asc[:12]])

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
