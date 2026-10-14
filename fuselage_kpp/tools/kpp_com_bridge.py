#!/usr/bin/env python3
"""Bridge + sniffer for JIYI K++ assistant <-> flight controller GPS traffic.

Wire format (same as fuselage_kpp): each byte is rotl3(clear ^ 0xDF).
Clear frames: EB | len | seq | sys | comp | msgid | payload | crc_lo | crc_hi

Typical com0com setup
---------------------
1. Install com0com and create a pair, e.g. COM10 <-> COM11.
2. Plug the real K++ USB serial (note its COM, e.g. COM3).
3. In Device Manager, confirm COM10/COM11 exist.
4. Run this bridge (forwards both ways and logs GPS messages):

     python kpp_com_bridge.py --fc COM3 --app COM11 --baud 115200

5. Open the official K++ assistant and connect to COM10 (the other half
   of the pair). Use the app normally outdoors until GPS looks good.
6. Stop the bridge with Ctrl+C. Capture is written to captures/*.jsonl
7. Analyze:

     python analyze_kpp_capture.py captures/<file>.jsonl

What we extract for GPS parity
------------------------------
- APP→FC: msgid 211, 220, REQUEST_DATA_STREAM (66) rates/ids
- FC→APP: GPS_RAW_INT (24), GPS2_RAW (124), GLOBAL_POSITION_INT (33),
  KppGpsPosition (203), KppGpsStatus (206), plus unknown ids (raw hex)
"""

from __future__ import annotations

import argparse
import json
import struct
import sys
import threading
import time
from datetime import datetime, timezone
from pathlib import Path

try:
    import serial
except ImportError:
    print("Install pyserial:  python -m pip install pyserial", file=sys.stderr)
    sys.exit(1)

WIRE_KEY = 0xDF
MAGIC = 0xEB
HEADER_LEN = 6
CRC_LEN = 2

# Known CRC_EXTRA values from fuselage_kpp mavlink_messages.dart
CRC_EXTRA: dict[int, int] = {
    0: 50,
    1: 124,
    20: 214,
    21: 159,
    22: 220,
    23: 168,
    24: 24,
    27: 144,
    29: 115,
    33: 104,
    35: 244,
    41: 28,
    43: 132,
    44: 221,
    45: 232,
    47: 153,
    51: 196,
    65: 118,
    66: 148,
    73: 38,
    76: 152,
    77: 143,
    116: 76,
    117: 128,
    118: 56,
    119: 116,
    120: 24,
    124: 87,
    129: 0,
    147: 154,
    203: 61,
    206: 215,
    211: 3,
    220: 81,
    253: 83,
}

GPS_FOCUS_IDS = {24, 33, 66, 124, 203, 206, 211, 220}

STREAM_NAMES = {
    0: "ALL",
    1: "RAW_SENSORS",
    2: "EXT_STATUS",
    3: "RC_CHANNELS",
    6: "POSITION",
    10: "EXTRA1",
    11: "EXTRA2",
    12: "EXTRA3",
    13: "KPP_AGRI1",
    14: "KPP_AGRI2",
}

FIX_LABELS = {
    0: "no_gps",
    1: "no_fix",
    2: "2d",
    3: "3d",
    4: "dgps",
    5: "rtk_float",
    6: "rtk_fixed",
}


def rotl8(value: int, bits: int) -> int:
    return ((value << bits) | (value >> (8 - bits))) & 0xFF


def decode_wire_byte(wire: int) -> int:
    return rotl8(wire, 5) ^ WIRE_KEY


def encode_wire_byte(clear: int) -> int:
    return rotl8(clear ^ WIRE_KEY, 3)


def x25_crc(data: bytes, crc: int = 0xFFFF) -> int:
    value = crc
    for byte in data:
        tmp = (byte ^ (value & 0xFF)) & 0xFF
        tmp = (tmp ^ ((tmp << 4) & 0xFF)) & 0xFF
        value = ((value >> 8) ^ (tmp << 8) ^ (tmp << 3) ^ (tmp >> 4)) & 0xFFFF
    return value


def u8(buf: bytes, off: int) -> int:
    return buf[off]


def u16(buf: bytes, off: int) -> int:
    return struct.unpack_from("<H", buf, off)[0]


def i32(buf: bytes, off: int) -> int:
    return struct.unpack_from("<i", buf, off)[0]


def u32(buf: bytes, off: int) -> int:
    return struct.unpack_from("<I", buf, off)[0]


def u64(buf: bytes, off: int) -> int:
    return struct.unpack_from("<Q", buf, off)[0]


def decode_gps_fields(msgid: int, payload: bytes) -> dict:
    """Best-effort field decode for GPS-related messages."""
    out: dict = {}
    try:
        if msgid == 24 and len(payload) >= 30:
            # time(8) lat lon alt eph epv vel cog fix sats
            out = {
                "lat_e7": i32(payload, 8),
                "lon_e7": i32(payload, 12),
                "alt_mm": i32(payload, 16),
                "eph": u16(payload, 20),
                "fix": u8(payload, 28),
                "sats": u8(payload, 29),
                "fix_label": FIX_LABELS.get(u8(payload, 28), str(u8(payload, 28))),
            }
        elif msgid == 124 and len(payload) >= 35:
            # time(8) lat lon alt dgps_age eph epv vel cog fix sats
            out = {
                "lat_e7": i32(payload, 8),
                "lon_e7": i32(payload, 12),
                "alt_mm": i32(payload, 16),
                "eph": u16(payload, 24),
                "fix": u8(payload, 32),
                "sats": u8(payload, 33),
                "fix_label": FIX_LABELS.get(u8(payload, 32), str(u8(payload, 32))),
            }
        elif msgid == 33 and len(payload) >= 28:
            out = {
                "lat_e7": i32(payload, 4),
                "lon_e7": i32(payload, 8),
                "alt_mm": i32(payload, 12),
                "relative_alt_mm": i32(payload, 16),
            }
        elif msgid == 203 and len(payload) >= 13:
            out = {
                "lat_e7": i32(payload, 0),
                "lon_e7": i32(payload, 4),
                "alt_mm": i32(payload, 8),
                "status": u8(payload, 12) if len(payload) > 12 else None,
                "gps1_fix": u8(payload, 13) if len(payload) > 13 else None,
                "gps1_sats": u8(payload, 14) if len(payload) > 14 else None,
                "gps2_fix": u8(payload, 15) if len(payload) > 15 else None,
                "gps2_sats": u8(payload, 16) if len(payload) > 16 else None,
                "payload_hex": payload.hex(),
            }
        elif msgid == 206 and len(payload) >= 5:
            # Current Fuselage layout hypothesis: [res, f1, s1, f2, s2, ...]
            layouts = {
                "skip_res": {
                    "res": u8(payload, 0),
                    "gps1_fix": u8(payload, 1),
                    "gps1_sats": u8(payload, 2),
                    "gps2_fix": u8(payload, 3),
                    "gps2_sats": u8(payload, 4),
                },
                "no_res": {
                    "gps1_fix": u8(payload, 0),
                    "gps1_sats": u8(payload, 1),
                    "gps2_fix": u8(payload, 2),
                    "gps2_sats": u8(payload, 3),
                },
            }
            out = {
                "payload_hex": payload.hex(),
                "layouts": layouts,
                # Primary decode matching fuselage_kpp today:
                "gps1_fix": layouts["skip_res"]["gps1_fix"],
                "gps1_sats": layouts["skip_res"]["gps1_sats"],
                "gps2_fix": layouts["skip_res"]["gps2_fix"],
                "gps2_sats": layouts["skip_res"]["gps2_sats"],
            }
        elif msgid == 66 and len(payload) >= 6:
            rate = u16(payload, 0)
            stream_id = u8(payload, 4)
            out = {
                "rate_hz": rate,
                "target_system": u8(payload, 2),
                "target_component": u8(payload, 3),
                "stream_id": stream_id,
                "stream": STREAM_NAMES.get(stream_id, f"id_{stream_id}"),
                "start": u8(payload, 5) == 1,
            }
        elif msgid in (211, 220):
            out = {"payload_hex": payload.hex()}
    except Exception as exc:  # noqa: BLE001 — sniffer must not die on odd frames
        out = {"decode_error": str(exc), "payload_hex": payload.hex()}
    return out


class FrameParser:
    def __init__(self) -> None:
        self._buf = bytearray()
        self.rejected = 0
        self.unknown_ok = 0

    def feed(self, wire: bytes) -> list[dict]:
        self._buf.extend(decode_wire_byte(b) for b in wire)
        frames: list[dict] = []
        while True:
            try:
                start = self._buf.index(MAGIC)
            except ValueError:
                self._buf.clear()
                break
            if start > 0:
                del self._buf[:start]
            if len(self._buf) < 2:
                break
            payload_len = self._buf[1]
            frame_len = HEADER_LEN + payload_len + CRC_LEN
            if len(self._buf) < frame_len:
                break
            frame = bytes(self._buf[:frame_len])
            parsed = self._decode(frame)
            if parsed is None:
                self.rejected += 1
                del self._buf[0]
                continue
            frames.append(parsed)
            del self._buf[:frame_len]
        return frames

    def _decode(self, frame: bytes) -> dict | None:
        payload_len = frame[1]
        seq, sysid, compid, msgid = frame[2], frame[3], frame[4], frame[5]
        payload = frame[HEADER_LEN : HEADER_LEN + payload_len]
        crc_recv = frame[HEADER_LEN + payload_len] | (frame[HEADER_LEN + payload_len + 1] << 8)
        extra = CRC_EXTRA.get(msgid)
        crc_ok = False
        if extra is not None:
            body = frame[1 : HEADER_LEN + payload_len] + bytes([extra])
            crc_ok = x25_crc(body) == crc_recv
            if not crc_ok:
                return None
        else:
            # Unknown id: keep raw frame so we can discover new GPS messages.
            self.unknown_ok += 1
            crc_ok = False
        return {
            "msgid": msgid,
            "seq": seq,
            "sys": sysid,
            "comp": compid,
            "len": payload_len,
            "crc_ok": crc_ok,
            "payload_hex": payload.hex(),
            "fields": decode_gps_fields(msgid, payload) if msgid in GPS_FOCUS_IDS or msgid >= 200 else {},
        }


class CaptureWriter:
    def __init__(self, path: Path) -> None:
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._fp = path.open("w", encoding="utf-8")
        self.count = 0
        self.gps_count = 0

    def write(self, direction: str, frame: dict) -> None:
        rec = {
            "t": datetime.now(timezone.utc).isoformat(),
            "dir": direction,
            **frame,
        }
        self._fp.write(json.dumps(rec, separators=(",", ":")) + "\n")
        self._fp.flush()
        self.count += 1
        if frame["msgid"] in GPS_FOCUS_IDS:
            self.gps_count += 1
            self._print_gps(direction, frame)

    def _print_gps(self, direction: str, frame: dict) -> None:
        mid = frame["msgid"]
        fields = frame.get("fields") or {}
        arrow = "APP->FC" if direction == "app" else "FC->APP"
        if mid == 206:
            print(
                f"[{arrow}] 206 STATUS  "
                f"gps1={fields.get('gps1_fix')}/{fields.get('gps1_sats')}s  "
                f"gps2={fields.get('gps2_fix')}/{fields.get('gps2_sats')}s  "
                f"raw={fields.get('payload_hex')}"
            )
        elif mid in (24, 124):
            name = "GPS1_RAW" if mid == 24 else "GPS2_RAW"
            lat = fields.get("lat_e7")
            lon = fields.get("lon_e7")
            print(
                f"[{arrow}] {name}  fix={fields.get('fix_label')}  "
                f"sats={fields.get('sats')}  lat={lat} lon={lon}"
            )
        elif mid == 203:
            print(
                f"[{arrow}] 203 POS  lat={fields.get('lat_e7')} "
                f"lon={fields.get('lon_e7')} alt={fields.get('alt_mm')} "
                f"flags={fields.get('flags')} raw={fields.get('payload_hex')}"
            )
        elif mid == 33:
            print(
                f"[{arrow}] 33 GLOBAL  lat={fields.get('lat_e7')} "
                f"lon={fields.get('lon_e7')} rel={fields.get('relative_alt_mm')}"
            )
        elif mid == 66:
            print(
                f"[{arrow}] 66 STREAM  {fields.get('stream')} "
                f"@{fields.get('rate_hz')}Hz start={fields.get('start')} "
                f"tgt={fields.get('target_system')}/{fields.get('target_component')}"
            )
        elif mid in (211, 220):
            print(f"[{arrow}] {mid} HANDSHAKE  {fields.get('payload_hex')}")

    def close(self) -> None:
        self._fp.close()


def pump(src: serial.Serial, dst: serial.Serial, direction: str, parser: FrameParser, cap: CaptureWriter, stop: threading.Event) -> None:
    while not stop.is_set():
        waiting = src.in_waiting
        chunk = src.read(waiting or 1)
        if not chunk:
            continue
        dst.write(chunk)
        dst.flush()
        for frame in parser.feed(chunk):
            cap.write(direction, frame)


def main() -> int:
    ap = argparse.ArgumentParser(description="K++ assistant<->FC COM bridge + GPS sniffer")
    ap.add_argument("--fc", required=True, help="Real K++ USB serial (e.g. COM3)")
    ap.add_argument("--app", required=True, help="com0com half for the bridge (e.g. COM11)")
    ap.add_argument("--baud", type=int, default=115200)
    ap.add_argument(
        "--out",
        default="",
        help="Capture jsonl path (default: captures/kpp_gps_<timestamp>.jsonl)",
    )
    args = ap.parse_args()

    out = Path(args.out) if args.out else Path(__file__).resolve().parent / "captures" / (
        f"kpp_gps_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jsonl"
    )

    print(f"FC  {args.fc} @ {args.baud}")
    print(f"APP {args.app} (assistant should open the OTHER com0com port)")
    print(f"LOG {out}")
    print("Connect the K++ assistant now. Ctrl+C to stop.\n")

    fc = serial.Serial(args.fc, args.baud, timeout=0.05)
    app = serial.Serial(args.app, args.baud, timeout=0.05)
    cap = CaptureWriter(out)
    stop = threading.Event()
    fc_parser, app_parser = FrameParser(), FrameParser()

    t1 = threading.Thread(target=pump, args=(fc, app, "fc", fc_parser, cap, stop), daemon=True)
    t2 = threading.Thread(target=pump, args=(app, fc, "app", app_parser, cap, stop), daemon=True)
    t1.start()
    t2.start()

    try:
        while True:
            time.sleep(1.0)
    except KeyboardInterrupt:
        print("\nStopping…")
    finally:
        stop.set()
        time.sleep(0.2)
        fc.close()
        app.close()
        cap.close()
        print(
            f"Saved {cap.count} frames ({cap.gps_count} GPS-focus) → {out}\n"
            f"Rejected sync bytes FC={fc_parser.rejected} APP={app_parser.rejected} "
            f"unknown_ids≈{fc_parser.unknown_ok + app_parser.unknown_ok}\n"
            f"Next:  python analyze_kpp_capture.py \"{out}\""
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
