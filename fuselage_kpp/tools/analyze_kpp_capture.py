#!/usr/bin/env python3
"""Summarize a K++ GPS capture from kpp_com_bridge.py for Fuselage parity work."""

from __future__ import annotations

import argparse
import json
import statistics
from collections import Counter, defaultdict
from pathlib import Path


GPS_IDS = {24, 33, 66, 124, 203, 206, 211, 220}


def load(path: Path) -> list[dict]:
    rows = []
    with path.open(encoding="utf-8-sig") as fp:
        for line in fp:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("capture", type=Path, help="captures/kpp_gps_*.jsonl")
    args = ap.parse_args()
    rows = load(args.capture)
    if not rows:
        print("Empty capture")
        return 1

    by_id = Counter((r["dir"], r["msgid"]) for r in rows)
    print(f"Frames: {len(rows)}")
    print("\n== Message counts (dir, msgid) ==")
    for (direction, msgid), n in sorted(by_id.items(), key=lambda x: (-x[1], x[0])):
        tag = " *" if msgid in GPS_IDS else ""
        print(f"  {direction:3}  msgid={msgid:3}  n={n}{tag}")

    print("\n== APP->FC stream / handshake (what Fuselage must request) ==")
    for r in rows:
        if r["dir"] != "app":
            continue
        if r["msgid"] in (66, 211, 220):
            print(f"  {r['t']}  {r['msgid']}  {r.get('fields')}")

    print("\n== msgid 206 payloads (compare layouts vs assistant sats) ==")
    seen206: Counter[str] = Counter()
    for r in rows:
        if r["msgid"] != 206:
            continue
        fields = r.get("fields") or {}
        hx = fields.get("payload_hex") or r.get("payload_hex")
        seen206[hx] += 1
    for hx, n in seen206.most_common(20):
        sample = next(
            (
                r
                for r in rows
                if r["msgid"] == 206
                and ((r.get("fields") or {}).get("payload_hex") or r.get("payload_hex")) == hx
            ),
            None,
        )
        layouts = ((sample or {}).get("fields") or {}).get("layouts") or {}
        fields = ((sample or {}).get("fields") or {})
        print(f"  n={n}  hex={hx}")
        if layouts:
            print(f"       skip_res={layouts.get('skip_res')}")
            print(f"       no_res  ={layouts.get('no_res')}")
        if fields:
            print(
                f"       decoded f1={fields.get('gps1_fix')} s1={fields.get('gps1_sats')} "
                f"f2={fields.get('gps2_fix')} s2={fields.get('gps2_sats')}"
            )

    print("\n== GPS_RAW / GPS2_RAW sat histogram (FC->APP) ==")
    for msgid, name in ((24, "GPS1_RAW"), (124, "GPS2_RAW")):
        sats = [
            (r.get("fields") or {}).get("sats")
            for r in rows
            if r["dir"] == "fc" and r["msgid"] == msgid and (r.get("fields") or {}).get("sats") is not None
        ]
        fixes = Counter(
            (r.get("fields") or {}).get("fix_label")
            for r in rows
            if r["dir"] == "fc" and r["msgid"] == msgid
        )
        if not sats:
            print(f"  {name}: none")
            continue
        print(
            f"  {name}: n={len(sats)}  sats min/med/max="
            f"{min(sats)}/{int(statistics.median(sats))}/{max(sats)}  fixes={dict(fixes)}"
        )

    print("\n== msgid 203 position samples ==")
    pos = [r for r in rows if r["msgid"] == 203 and r["dir"] == "fc"]
    nonzero = [
        r
        for r in pos
        if (r.get("fields") or {}).get("lat_e7") not in (None, 0)
        or (r.get("fields") or {}).get("lon_e7") not in (None, 0)
    ]
    print(f"  total={len(pos)}  nonzero_latlon={len(nonzero)}")
    for r in nonzero[:5]:
        f = r.get("fields") or {}
        print(f"  lat={f.get('lat_e7')} lon={f.get('lon_e7')} alt={f.get('alt_mm')} flags={f.get('flags')} hex={f.get('payload_hex')}")

    print("\n== Unknown / high msgid (>=200) raw (discover new GPS msgs) ==")
    unknown = Counter()
    samples: dict[int, str] = {}
    for r in rows:
        mid = r["msgid"]
        if mid in GPS_IDS:
            continue
        if mid < 200 and r.get("crc_ok"):
            continue
        unknown[mid] += 1
        samples.setdefault(mid, r.get("payload_hex", ""))
    for mid, n in unknown.most_common(30):
        print(f"  msgid={mid} n={n} sample_hex={samples.get(mid, '')[:40]}")

    print("\n== Recommended Fuselage parity checklist ==")
    streams = [
        (r.get("fields") or {})
        for r in rows
        if r["dir"] == "app" and r["msgid"] == 66
    ]
    if streams:
        print("  Stream requests seen:")
        for s in streams:
            print(f"    - {s.get('stream')} @{s.get('rate_hz')}Hz tgt={s.get('target_system')}/{s.get('target_component')}")
    else:
        print("  No REQUEST_DATA_STREAM (66) from APP - assistant may rely on defaults only.")

    raw1 = any(r["msgid"] == 24 and r["dir"] == "fc" for r in rows)
    raw2 = any(r["msgid"] == 124 and r["dir"] == "fc" for r in rows)
    print(f"  FC sends GPS_RAW_INT (24): {raw1}")
    print(f"  FC sends GPS2_RAW (124): {raw2}")
    print(f"  FC sends KppGpsPosition (203): {any(r['msgid']==203 and r['dir']=='fc' for r in rows)}")
    print(f"  FC sends KppGpsStatus (206): {any(r['msgid']==206 and r['dir']=='fc' for r in rows)}")
    print("\nShare this summary (or the .jsonl) and we will mirror the assistant's GPS path in Fuselage.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
