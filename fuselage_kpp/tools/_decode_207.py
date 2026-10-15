#!/usr/bin/env python3
"""Explore msgid 207 payload structure from Fuselage captures."""
from __future__ import annotations

import json
import struct
import sys
from collections import Counter
from pathlib import Path


def main() -> int:
    path = Path(sys.argv[1])
    rows = [json.loads(l) for l in path.read_text(encoding="utf-8-sig").splitlines() if l.strip()]
    xs = [r for r in rows if r.get("msgid") == 207 and r.get("payload_hex")]
    print("207 count", len(xs))
    if not xs:
        return 1

    # length histogram
    lens = Counter(len(bytes.fromhex(r["payload_hex"])) for r in xs)
    print("lengths", lens)

    # find varying bytes
    payloads = [bytes.fromhex(r["payload_hex"]) for r in xs]
    n = min(len(p) for p in payloads)
    print(f"comparing first {n} bytes across {len(payloads)} frames")
    for i in range(n):
        vals = Counter(p[i] for p in payloads)
        if len(vals) > 1:
            print(f"  offset {i:2d}: {vals.most_common(8)}")

    print("\nSample decode attempts on first 3:")
    for p in payloads[:3]:
        print(" hex", p.hex())
        # floats at various offsets
        for off in range(0, min(60, len(p) - 3), 4):
            f = struct.unpack_from("<f", p, off)[0]
            i32 = struct.unpack_from("<i", p, off)[0]
            u32 = struct.unpack_from("<I", p, off)[0]
            if abs(f) > 1e-3 and abs(f) < 1e6:
                print(f"  @{off}: float={f:.6g} i32={i32} u32={u32}")
        # trailing 20 bytes
        print("  tail20", list(p[-20:]))
        # look for 206-like subsequence
        for i in range(len(p) - 5):
            if p[i : i + 2] == b"\x01\x01" and p[i + 3 : i + 5] in (b"\x01\x01",):
                print(f"  206-like @{i}: {list(p[i : i + 6])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
