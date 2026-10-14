#!/usr/bin/env python3
"""Open the real K++ COM port and log GPS MAVLink frames (no com0com needed).

Usage (FC on COM3, close the assistant / Fuselage first):

  python sniff_fc_gps.py COM3

Writes Documents/FuselageKppCaptures/kpp_sniff_*.jsonl and prints GPS lines.
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

from kpp_mavlink_wire import GPS_FOCUS_IDS, FrameParser

try:
    import serial
except ImportError:
    raise SystemExit("pip install pyserial") from None


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("port", help="e.g. COM3")
    ap.add_argument("--baud", type=int, default=115200)
    ap.add_argument("--seconds", type=int, default=45)
    args = ap.parse_args()

    home = Path.home() / "Documents" / "FuselageKppCaptures"
    home.mkdir(parents=True, exist_ok=True)
    out = home / f"kpp_sniff_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jsonl"
    print(f"Listening {args.port} @ {args.baud} for {args.seconds}s")
    print(f"Log -> {out}")
    print("Close Fuselage/assistant first so the port is free.\n")

    ser = serial.Serial(args.port, args.baud, timeout=0.05)
    parser = FrameParser()
    t0 = time.time()
    n = 0
    with out.open("w", encoding="utf-8") as fp:
        while time.time() - t0 < args.seconds:
            chunk = ser.read(ser.in_waiting or 1)
            if not chunk:
                continue
            for frame in parser.feed(chunk):
                mid = frame["msgid"]
                if mid not in GPS_FOCUS_IDS and mid < 200:
                    continue
                rec = {"t": datetime.now(timezone.utc).isoformat(), "dir": "fc", **frame}
                fp.write(json.dumps(rec, separators=(",", ":")) + "\n")
                fp.flush()
                n += 1
                fields = frame.get("fields") or {}
                if mid in (24, 124, 203, 206, 25, 33):
                    print(f"msgid={mid} {fields}")
    ser.close()
    print(f"\nSaved {n} GPS-focus frames -> {out}")
    print(f"Next: python analyze_kpp_capture.py \"{out}\"")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
