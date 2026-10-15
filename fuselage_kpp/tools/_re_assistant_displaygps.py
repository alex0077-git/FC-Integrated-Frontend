#!/usr/bin/env python3
"""Disassemble Base_sensorDlg GPS signal branch near string refs."""
from __future__ import annotations

import struct
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    exe = next(root.rglob("JIYI221014.exe"))
    data = exe.read_bytes()

    # First no_fix ref was at file 83777 — dump a larger window upward for cmps
    for name, ref in [
        ("nofix", 83777),
        ("weak", 85009),
        ("good", 86433),
        ("high", 86049),
    ]:
        start = max(0, ref - 200)
        chunk = data[start:ref]
        print(f"\n==== {name} ref@{ref} dump[{start}:{ref}] ====")
        # find cmp/test immediates
        i = 0
        while i < len(chunk) - 2:
            b0, b1 = chunk[i], chunk[i + 1]
            # cmp reg, imm8: 83 F8 ib / 83 F9 ib ...
            if b0 == 0x83 and chunk[i + 1] in range(0xF8, 0x100):
                print(f"  @{start+i:#x}: cmp r,{chunk[i+2]}")
                i += 3
                continue
            if b0 == 0x3C:  # cmp al, ib
                print(f"  @{start+i:#x}: cmp al,{b1}")
                i += 2
                continue
            if b0 == 0x80 and chunk[i + 1] in (0xF8, 0xF9, 0xFA, 0xFB):
                print(f"  @{start+i:#x}: cmp r8,{chunk[i+2]}")
                i += 3
                continue
            i += 1

    # Search for displayGps1data slot implementation via moc index
    # Qt: activated by signal; look for "displayGps1data(int,int)" only once in code path
    # Print bytes around second string occurrence (might be in .rdata duplicate)
    print("\nstring hits", [data.find(b"displayGps1data"), data.find(b"displayGps1data", 800000)])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
