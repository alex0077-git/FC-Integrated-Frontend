#!/usr/bin/env python3
"""Quick inspect of FuselageKppCaptures jsonl for GPS parity."""
from __future__ import annotations

import json
import struct
import sys
from collections import Counter
from pathlib import Path


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "")
    if not path.is_file():
        print("usage: _inspect_capture.py <capture.jsonl>")
        return 1
    rows = [json.loads(line) for line in path.read_text(encoding="utf-8-sig").splitlines() if line.strip()]
    print("total", len(rows))
    print("dirs", Counter(r.get("dir") for r in rows))
    print("msgids", Counter(r.get("msgid") for r in rows).most_common(25))

    for mid in (206, 203, 33, 24, 124, 66, 211, 220, 207):
        xs = [r for r in rows if r.get("msgid") == mid]
        print(f"\n=== msgid {mid} n={len(xs)} ===")
        if not xs:
            continue
        for r in xs[:3]:
            print(json.dumps(r)[:500])

    print("\n== 206 payload hex histogram ==")
    c: Counter[str] = Counter()
    for r in rows:
        if r.get("msgid") != 206:
            continue
        hx = (r.get("fields") or {}).get("payload_hex") or r.get("payload_hex") or ""
        c[hx] += 1
    for hx, n in c.most_common(15):
        print(f"  n={n} hex={hx}")
        if hx:
            b = bytes.fromhex(hx)
            print(f"       bytes={list(b)}")
            if len(b) >= 5:
                print(f"       as [res,f1,s1,f2,s2]={b[0], b[1], b[2], b[3], b[4]}")
                print(f"       as [f1,s1,f2,s2,x]={b[0], b[1], b[2], b[3], b[4]}")

    print("\n== 203 lat/lon + tail ==")
    z = nz = 0
    tails: Counter[str] = Counter()
    for r in rows:
        if r.get("msgid") != 203:
            continue
        hx = r.get("payload_hex") or ""
        f = r.get("fields") or {}
        lat = f.get("lat_e7")
        lon = f.get("lon_e7")
        if lat in (None, 0) and lon in (None, 0):
            z += 1
        else:
            nz += 1
        if len(hx) >= 34:
            tails[hx[24:]] += 1  # after lat/lon/alt (12 bytes = 24 hex)
    print(f"  zero={z} nonzero={nz}")
    print("  tail hex top:")
    for hx, n in tails.most_common(10):
        print(f"    n={n} tail={hx}")
        if hx:
            b = bytes.fromhex(hx)
            print(f"         bytes={list(b)}")

    print("\n== 33 GLOBAL lat/lon ==")
    z = nz = 0
    for r in rows:
        if r.get("msgid") != 33:
            continue
        f = r.get("fields") or {}
        if f.get("lat_e7") in (None, 0) and f.get("lon_e7") in (None, 0):
            z += 1
        else:
            nz += 1
    print(f"  zero={z} nonzero={nz}")

    print("\n== decoded fields for 206 (as Fuselage stored) ==")
    field_c: Counter[str] = Counter()
    for r in rows:
        if r.get("msgid") != 206:
            continue
        f = r.get("fields") or {}
        key = f"f1={f.get('gps1_fix')} s1={f.get('gps1_sats')} f2={f.get('gps2_fix')} s2={f.get('gps2_sats')}"
        field_c[key] += 1
    for k, n in field_c.most_common(10):
        print(f"  n={n} {k}")

    print("\n== decoded fields for 203 ==")
    field_c = Counter()
    for r in rows:
        if r.get("msgid") != 203:
            continue
        f = r.get("fields") or {}
        key = (
            f"lat={f.get('lat_e7')} status={f.get('status')} "
            f"f1={f.get('gps1_fix')} s1={f.get('gps1_sats')} "
            f"f2={f.get('gps2_fix')} s2={f.get('gps2_sats')}"
        )
        field_c[key] += 1
    for k, n in field_c.most_common(10):
        print(f"  n={n} {k}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
