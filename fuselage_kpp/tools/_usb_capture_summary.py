#!/usr/bin/env python3
from __future__ import annotations

import json
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path


def parse_t(s: str) -> datetime:
    if s.endswith("Z"):
        s = s[:-1] + "+00:00"
    return datetime.fromisoformat(s)


def load(path: Path) -> list[dict]:
    rows = []
    with path.open(encoding="utf-8-sig") as fp:
        for line in fp:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def main() -> int:
    capt = Path.home() / "Documents" / "FuselageKppCaptures"
    files = sorted([p for p in capt.glob("kpp_wire_*.jsonl") if p.stat().st_size > 0], key=lambda p: p.stat().st_mtime)

    print("FILE SUMMARY (focus msgids)")
    print(
        f"{'file':44} {'n':>6} {'dur_s':>8} {'24':>10} {'124':>8} {'206':>10} {'207':>10} "
        f"{'b2set':>12} {'207[73]':>14} {'n66':>4}"
    )
    for p in files:
        rows = load(p)
        if not rows:
            continue
        ts = [parse_t(r["t"]) for r in rows if r.get("t")]
        dur = max((ts[-1] - ts[0]).total_seconds(), 1e-9) if len(ts) >= 2 else 0.0
        c = Counter(r.get("msgid") for r in rows)

        def cell(mid: int) -> str:
            n = c.get(mid, 0)
            return f"{n}:{n/dur:.2f}" if n else "NO"

        b2 = set()
        for r in rows:
            if r.get("msgid") != 206:
                continue
            hx = r.get("payload_hex") or ""
            if len(hx) >= 6:
                b = bytes.fromhex(hx)
                if len(b) > 2:
                    b2.add(b[2])
        h73 = Counter()
        for r in rows:
            if r.get("msgid") != 207:
                continue
            hx = r.get("payload_hex") or ""
            if not hx:
                continue
            b = bytes.fromhex(hx)
            if len(b) > 73:
                h73[b[73]] += 1
        n66 = sum(1 for r in rows if r.get("msgid") == 66 and r.get("dir") != "fc")
        b2s = str(sorted(b2)) if b2 else "-"
        s73 = str(dict(sorted(h73.items()))) if h73 else "-"
        print(
            f"{p.name:44} {len(rows):6d} {dur:8.1f} {cell(24):>10} {cell(124):>8} {cell(206):>10} {cell(207):>10} "
            f"{b2s:>12} {s73:>14} {n66:4d}"
        )

    print("\n\nCAPTURES WITH APP msgid 66 — full ordered list")
    for p in files:
        rows = load(p)
        seq = []
        for r in rows:
            if r.get("msgid") != 66 or r.get("dir") == "fc":
                continue
            hx = r.get("payload_hex") or ""
            fld = r.get("fields") or {}
            if hx and len(bytes.fromhex(hx)) >= 6:
                b = bytes.fromhex(hx)
                rate = b[0] | (b[1] << 8)
                seq.append((r.get("t"), b[2], b[3], b[4], rate, b[5], "hex"))
            elif "stream_id" in fld:
                seq.append(
                    (
                        r.get("t"),
                        int(fld.get("target_system", -1)),
                        int(fld.get("target_component", -1)),
                        int(fld["stream_id"]),
                        int(fld.get("rate_hz", -1)),
                        1 if fld.get("start", True) else 0,
                        "fields",
                    )
                )
        if not seq:
            continue
        print(f"\n### {p.name} n66={len(seq)}")
        # also show 211/220 around connect
        for r in rows:
            if r.get("msgid") in (211, 220) and r.get("dir") != "fc":
                print(f"  t={r.get('t')} msgid={r.get('msgid')} dir={r.get('dir')} hex={r.get('payload_hex')} fields={r.get('fields')}")
        for i, (t, ts_, tc, sid, rate, st, src) in enumerate(seq, 1):
            print(
                f"  [{i:02d}] t={t} target_system={ts_} target_component={tc} "
                f"req_stream_id={sid} req_message_rate={rate} start_stop={st} ({src})"
            )

    print("\n\n21-SAT STYLE HITS (msgid24[29] or 124[33] or 207[73] >= 18)")
    for p in files:
        rows = load(p)
        hits = []
        for i, r in enumerate(rows):
            mid = r.get("msgid")
            hx = r.get("payload_hex") or ""
            if not hx:
                continue
            b = bytes.fromhex(hx)
            if mid == 24 and len(b) > 29 and b[29] >= 18:
                hits.append((i, mid, b[28], b[29], r.get("t")))
            elif mid == 124 and len(b) > 33 and b[33] >= 18:
                hits.append((i, mid, b[32], b[33], r.get("t")))
            elif mid == 207 and len(b) > 73 and b[73] >= 18:
                hits.append((i, mid, None, b[73], r.get("t")))
        if not hits:
            continue
        print(f"\n### {p.name} hits={len(hits)}")
        # max sat
        max_s = max(h[3] for h in hits)
        print(f"  max_byte_value={max_s}")
        print(f"  first_hit={hits[0]}")
        idx = hits[0][0]
        print("  msgid66 before first hit:")
        n = 0
        for j in range(idx):
            rr = rows[j]
            if rr.get("msgid") != 66 or rr.get("dir") == "fc":
                continue
            hx = rr.get("payload_hex") or ""
            n += 1
            if hx and len(bytes.fromhex(hx)) >= 6:
                b = bytes.fromhex(hx)
                rate = b[0] | (b[1] << 8)
                print(
                    f"    [{n:02d}] sys={b[2]} comp={b[3]} stream_id={b[4]} rate={rate} start_stop={b[5]}"
                )
            else:
                print(f"    [{n:02d}] fields={rr.get('fields')}")
        if n == 0:
            print("    (none in this file before first hit)")

    # 207 detail for a recent agri capture with 206
    print("\n\nSAMPLE 207 TIMELINE (latest file with 207)")
    for p in reversed(files):
        rows = load(p)
        xs = [r for r in rows if r.get("msgid") == 207 and r.get("payload_hex")]
        if not xs:
            continue
        print(f"file={p.name} n={len(xs)}")
        last = None
        ntr = 0
        for r in xs:
            b = bytes.fromhex(r["payload_hex"])
            if len(b) < 74:
                continue
            trip = (b[65], b[69], b[73])
            if trip != last:
                ntr += 1
                if ntr <= 30:
                    print(f"  t={r['t']} [65]={b[65]} [69]={b[69]} [73]={b[73]}")
                last = trip
        h73 = Counter(bytes.fromhex(r["payload_hex"])[73] for r in xs if len(bytes.fromhex(r["payload_hex"])) > 73)
        print(f"  all distinct [73]={dict(sorted(h73.items()))} transitions={ntr}")
        break

    print("\n\nSAMPLE 206 TIMELINE (latest file with 206)")
    for p in reversed(files):
        rows = [r for r in load(p) if r.get("msgid") == 206 and r.get("payload_hex")]
        if not rows:
            continue
        print(f"file={p.name} n={len(rows)}")
        last = None
        ntr = 0
        for r in rows:
            b = bytes.fromhex(r["payload_hex"])
            if tuple(b) != last:
                ntr += 1
                if ntr <= 40:
                    print(f"  t={r['t']} bytes={[f'{x:02X}' for x in b]}")
                last = tuple(b)
        b2 = Counter(bytes.fromhex(r["payload_hex"])[2] for r in rows if len(bytes.fromhex(r["payload_hex"])) > 2)
        print(f"  distinct byte[2]={dict(sorted(b2.items()))} transitions={ntr}")
        break
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
