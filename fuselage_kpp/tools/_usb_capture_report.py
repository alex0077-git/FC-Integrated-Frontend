#!/usr/bin/env python3
"""Byte-level USB capture report (no field-meaning guesses beyond stated offsets)."""
from __future__ import annotations

import json
import statistics
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path


FOCUS = {24, 124, 206, 207, 66, 211, 220}


def parse_t(s: str) -> datetime:
    # 2026-10-14T09:46:34.081314Z
    if s.endswith("Z"):
        s = s[:-1] + "+00:00"
    return datetime.fromisoformat(s)


def load(path: Path) -> list[dict]:
    rows = []
    with path.open(encoding="utf-8-sig") as fp:
        for line in fp:
            line = line.strip()
            if not line:
                continue
            rows.append(json.loads(line))
    return rows


def duration_s(rows: list[dict]) -> float:
    ts = [parse_t(r["t"]) for r in rows if r.get("t")]
    if len(ts) < 2:
        return 0.0
    return max((ts[-1] - ts[0]).total_seconds(), 1e-9)


def u8(b: bytes, i: int) -> int | None:
    return b[i] if len(b) > i else None


def report(path: Path) -> None:
    rows = load(path)
    if not rows:
        print(f"\n### {path.name}\nEmpty\n")
        return
    dur = duration_s(rows)
    by_id = Counter(r.get("msgid") for r in rows)
    print(f"\n{'='*72}")
    print(f"### {path.name}")
    print(f"frames={len(rows)}  duration_s={dur:.3f}  dirs={Counter(r.get('dir') for r in rows)}")
    print("\n-- frames per msgid (count, rate/s) --")
    for mid, n in by_id.most_common():
        print(f"  msgid={mid:3d}  n={n:6d}  rate={n/dur:8.3f}/s")

    print("\n-- focus presence --")
    for mid in (24, 124, 206, 207):
        n = by_id.get(mid, 0)
        print(f"  msgid {mid}: {'YES' if n else 'NO '}  n={n}  rate={(n/dur if n else 0):.3f}/s")

    # msgid 66 host->device (app)
    print("\n-- msgid 66 REQUEST_DATA_STREAM (dir=app), order sent --")
    n66 = 0
    for r in rows:
        if r.get("msgid") != 66 or r.get("dir") not in ("app", "host", "gcs"):
            # also accept missing dir if sys=255 typical GCS
            if r.get("msgid") != 66:
                continue
            if r.get("dir") == "fc":
                continue
        hx = r.get("payload_hex") or ""
        if not hx:
            fld = r.get("fields") or {}
            # reconstruct from fields if present
            if all(k in fld for k in ("rate_hz", "stream_id", "target_system", "target_component")):
                rate = int(fld["rate_hz"])
                ts_ = int(fld["target_system"])
                tc = int(fld["target_component"])
                sid = int(fld["stream_id"])
                start = 1 if fld.get("start", True) else 0
                n66 += 1
                print(
                    f"  [{n66:02d}] t={r.get('t')}  target_system={ts_} target_component={tc} "
                    f"req_stream_id={sid} req_message_rate={rate} start_stop={start}"
                )
                continue
            continue
        b = bytes.fromhex(hx)
        if len(b) < 6:
            print(f"  short payload len={len(b)} hex={hx}")
            continue
        # MAVLink REQUEST_DATA_STREAM: rate u16, target_system u8, target_component u8, stream_id u8, start_stop u8
        rate = b[0] | (b[1] << 8)
        ts_ = b[2]
        tc = b[3]
        sid = b[4]
        start = b[5]
        n66 += 1
        print(
            f"  [{n66:02d}] t={r.get('t')}  target_system={ts_} target_component={tc} "
            f"req_stream_id={sid} req_message_rate={rate} start_stop={start}"
        )
    if n66 == 0:
        print("  (none)")

    # 206
    print("\n-- msgid 206 payloads (6 bytes) over time --")
    c206 = Counter()
    byte2 = Counter()
    rows206 = [r for r in rows if r.get("msgid") == 206]
    # sample timeline: first/last and every change
    prev = None
    changes = 0
    for r in rows206:
        hx = r.get("payload_hex") or ""
        if not hx:
            continue
        b = bytes.fromhex(hx)
        key = tuple(b)
        c206[hx] += 1
        if len(b) > 2:
            byte2[b[2]] += 1
        if key != prev:
            changes += 1
            if changes <= 40 or r is rows206[-1]:
                print(f"  t={r.get('t')}  [{', '.join(f'{x:02X}' for x in b)}]")
            prev = key
    if len(rows206) > 40 and changes > 40:
        print(f"  ... ({changes} distinct transitions total; showing first 40 transitions)")
    print(f"  distinct full payloads: {len(c206)}")
    for hx, n in c206.most_common(12):
        print(f"    n={n:5d}  {hx}")
    print(f"  distinct values of byte[2]: {sorted(byte2)}  counts={dict(sorted(byte2.items()))}")

    # 207
    print("\n-- msgid 207 (expect len=75): bytes [65], [69], [73] over time --")
    rows207 = [r for r in rows if r.get("msgid") == 207 and r.get("payload_hex")]
    if not rows207:
        print("  (none)")
    else:
        lens = Counter(len(bytes.fromhex(r["payload_hex"])) for r in rows207)
        print(f"  lengths={dict(lens)}")
        prev_t = None
        printed = 0
        last_trip = None
        for r in rows207:
            b = bytes.fromhex(r["payload_hex"])
            if len(b) < 74:
                continue
            trip = (b[65], b[69], b[73])
            if trip != last_trip:
                printed += 1
                if printed <= 50:
                    print(
                        f"  t={r.get('t')}  [65]={b[65]:3d} (0x{b[65]:02X})  "
                        f"[69]={b[69]:3d} (0x{b[69]:02X})  [73]={b[73]:3d} (0x{b[73]:02X})"
                    )
                last_trip = trip
        # histograms
        h65 = Counter(bytes.fromhex(r["payload_hex"])[65] for r in rows207 if len(bytes.fromhex(r["payload_hex"])) > 73)
        h69 = Counter(bytes.fromhex(r["payload_hex"])[69] for r in rows207 if len(bytes.fromhex(r["payload_hex"])) > 73)
        h73 = Counter(bytes.fromhex(r["payload_hex"])[73] for r in rows207 if len(bytes.fromhex(r["payload_hex"])) > 73)
        print(f"  distinct [65]={sorted(h65)} counts={dict(sorted(h65.items()))}")
        print(f"  distinct [69]={sorted(h69)} counts={dict(sorted(h69.items()))}")
        print(f"  distinct [73]={sorted(h73)} counts={dict(sorted(h73.items()))}")
        print(f"  transitions_printed={min(printed,50)} total_transitions={printed}")

    # 24 / 124
    for mid, name, fix_off, sat_off, expect_len in (
        (24, "GPS_RAW_INT", 28, 29, 30),
        (124, "GPS2_RAW", 32, 33, 35),
    ):
        print(f"\n-- msgid {mid} ({name}): fix@[{fix_off}] sats@[{sat_off}] --")
        xs = [r for r in rows if r.get("msgid") == mid and r.get("payload_hex")]
        if not xs:
            print("  (none)")
            continue
        pairs = Counter()
        for r in xs:
            b = bytes.fromhex(r["payload_hex"])
            if len(b) <= sat_off:
                continue
            pairs[(b[fix_off], b[sat_off])] += 1
        print(f"  n={len(xs)}  payload_lens={Counter(len(bytes.fromhex(r['payload_hex'])) for r in xs)}")
        print(f"  (fix_type, satellites_visible) histogram:")
        for (fix, sats), n in pairs.most_common(20):
            print(f"    fix={fix} sats={sats}  n={n}")
        # first/last samples
        for label, r in (("first", xs[0]), ("last", xs[-1])):
            b = bytes.fromhex(r["payload_hex"])
            print(
                f"  {label}: t={r.get('t')} fix={b[fix_off] if len(b)>fix_off else None} "
                f"sats={b[sat_off] if len(b)>sat_off else None}"
            )


def find_21_sats(capt_dir: Path) -> None:
    print(f"\n{'='*72}")
    print("### Search for satellites_visible ~= 21 (msgid 24/124 offsets)")
    hits = []
    for path in sorted(capt_dir.glob("kpp_wire_*.jsonl")):
        if path.stat().st_size == 0:
            continue
        rows = load(path)
        for i, r in enumerate(rows):
            mid = r.get("msgid")
            hx = r.get("payload_hex") or ""
            if not hx:
                continue
            b = bytes.fromhex(hx)
            if mid == 24 and len(b) > 29 and b[29] >= 18:
                hits.append((path, i, r, 24, b[28], b[29]))
            if mid == 124 and len(b) > 33 and b[33] >= 18:
                hits.append((path, i, r, 124, b[32], b[33]))
            # also check 207[73]
            if mid == 207 and len(b) > 73 and b[73] >= 18:
                hits.append((path, i, r, 207, None, b[73]))
    if not hits:
        print("  no frames with sats>=18 at stated offsets")
        return
    # group by file
    by_file: dict[Path, list] = defaultdict(list)
    for h in hits:
        by_file[h[0]].append(h)
    for path, hs in by_file.items():
        print(f"\n-- {path.name} --")
        sats_vals = sorted({h[5] for h in hs})
        print(f"  hit_count={len(hs)}  sat_values_seen={sats_vals}")
        # pick first hit with ~21
        target = next((h for h in hs if h[5] == 21), hs[0])
        path, idx, r, mid, fix, sats = target
        print(f"  example: msgid={mid} fix={fix} sats={sats} t={r.get('t')} idx={idx}")
        rows = load(path)
        print("  msgid 66 frames BEFORE this example (dir!=fc):")
        n = 0
        for j in range(0, idx):
            rr = rows[j]
            if rr.get("msgid") != 66:
                continue
            if rr.get("dir") == "fc":
                continue
            hx = rr.get("payload_hex") or ""
            if hx and len(bytes.fromhex(hx)) >= 6:
                b = bytes.fromhex(hx)
                rate = b[0] | (b[1] << 8)
                n += 1
                print(
                    f"    [{n:02d}] t={rr.get('t')} target_system={b[2]} target_component={b[3]} "
                    f"req_stream_id={b[4]} req_message_rate={rate} start_stop={b[5]}"
                )
            else:
                fld = rr.get("fields") or {}
                n += 1
                print(f"    [{n:02d}] t={rr.get('t')} fields={fld}")
        if n == 0:
            print("    (none before this frame in file)")


def compare_66(capt_dir: Path) -> None:
    print(f"\n{'='*72}")
    print("### msgid 66 sequences across captures (for official vs ours compare)")
    for path in sorted(capt_dir.glob("kpp_wire_*.jsonl")):
        if path.stat().st_size < 1000:
            continue
        rows = load(path)
        seq = []
        for r in rows:
            if r.get("msgid") != 66 or r.get("dir") == "fc":
                continue
            hx = r.get("payload_hex") or ""
            if hx and len(bytes.fromhex(hx)) >= 6:
                b = bytes.fromhex(hx)
                rate = b[0] | (b[1] << 8)
                seq.append((b[2], b[3], b[4], rate, b[5]))
            else:
                fld = r.get("fields") or {}
                if "stream_id" in fld:
                    seq.append(
                        (
                            int(fld.get("target_system", -1)),
                            int(fld.get("target_component", -1)),
                            int(fld["stream_id"]),
                            int(fld.get("rate_hz", -1)),
                            1 if fld.get("start", True) else 0,
                        )
                    )
        if not seq:
            continue
        # compact signature
        sig = tuple(seq)
        print(f"\n{path.name}: n66={len(seq)}")
        for i, (ts_, tc, sid, rate, st) in enumerate(seq, 1):
            print(f"  [{i:02d}] sys={ts_} comp={tc} stream_id={sid} rate={rate} start_stop={st}")


def main() -> int:
    capt = Path.home() / "Documents" / "FuselageKppCaptures"
    files = sorted([p for p in capt.glob("kpp_wire_*.jsonl") if p.stat().st_size > 0], key=lambda p: p.stat().st_mtime)
    print(f"Capture dir: {capt}")
    print(f"Non-empty files: {len(files)}")
    # Full detail on all non-trivial; summarize tiny ones lightly
    for p in files:
        if p.stat().st_size < 500:
            print(f"\n### {p.name} size={p.stat().st_size} (skip detail)")
            continue
        report(p)
    find_21_sats(capt)
    compare_66(capt)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
