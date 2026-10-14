#!/usr/bin/env python3
"""Shared K++ wire decode (rotl3 ^ 0xDF) + GPS-focused MAVLink frame parser."""

from __future__ import annotations

import struct
from dataclasses import dataclass, field
from typing import Any

WIRE_KEY = 0xDF
MAGIC = 0xEB
HEADER_LEN = 6
CRC_LEN = 2

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


def decode_gps_fields(msgid: int, payload: bytes) -> dict[str, Any]:
    out: dict[str, Any] = {}
    try:
        if msgid == 24 and len(payload) >= 30:
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
                "gps1_fix": layouts["skip_res"]["gps1_fix"],
                "gps1_sats": layouts["skip_res"]["gps1_sats"],
                "gps2_fix": layouts["skip_res"]["gps2_fix"],
                "gps2_sats": layouts["skip_res"]["gps2_sats"],
            }
        elif msgid == 66 and len(payload) >= 6:
            stream_id = u8(payload, 4)
            out = {
                "rate_hz": u16(payload, 0),
                "target_system": u8(payload, 2),
                "target_component": u8(payload, 3),
                "stream_id": stream_id,
                "stream": STREAM_NAMES.get(stream_id, f"id_{stream_id}"),
                "start": u8(payload, 5) == 1,
            }
        elif msgid in (211, 220):
            out = {"payload_hex": payload.hex()}
    except Exception as exc:  # noqa: BLE001
        out = {"decode_error": str(exc), "payload_hex": payload.hex()}
    return out


@dataclass
class FrameParser:
    rejected: int = 0
    unknown_ok: int = 0
    _buf: bytearray = field(default_factory=bytearray)

    def feed(self, wire: bytes) -> list[dict[str, Any]]:
        self._buf.extend(decode_wire_byte(b) for b in wire)
        frames: list[dict[str, Any]] = []
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

    def _decode(self, frame: bytes) -> dict[str, Any] | None:
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
            self.unknown_ok += 1
        return {
            "msgid": msgid,
            "seq": seq,
            "sys": sysid,
            "comp": compid,
            "len": payload_len,
            "crc_ok": crc_ok,
            "payload_hex": payload.hex(),
            "fields": decode_gps_fields(msgid, payload)
            if msgid in GPS_FOCUS_IDS or msgid >= 200
            else {},
        }
