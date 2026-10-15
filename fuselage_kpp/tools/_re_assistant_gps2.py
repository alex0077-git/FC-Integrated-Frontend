#!/usr/bin/env python3
"""Deeper RE: msgid tables + signal_sendGps emit sites in JIYI221014."""
from __future__ import annotations

import re
import struct
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    exe = next(root.rglob("JIYI221014.exe"))
    data = exe.read_bytes()

    # Dump msgid table around first 206 le32
    pos = data.find(struct.pack("<I", 206))
    print("table around first 206 @", pos)
    for off in range(pos - 64, pos + 128, 4):
        if off < 0:
            continue
        v = struct.unpack_from("<I", data, off)[0]
        if v < 300:
            print(f"  {off}: {v}")

    # All 206 le32 contexts
    pat = struct.pack("<I", 206)
    start = 0
    while True:
        i = data.find(pat, start)
        if i < 0:
            break
        print(f"\n206@{i} neighbors:", [struct.unpack_from("<I", data, i + d)[0] for d in range(-16, 20, 4)])
        start = i + 1

    # Find PE sections to convert file off -> VA if needed
    # Search for relative references to string "signal_sendGps1Data" in .rdata/.text
    # Qt moc often has string then method index; emitting code loads string address.

    # Search UTF-16 LE for GPS1
    for s in ["GPS1", "GPS2", "No Fix", "RTK Fix", "DGPS fix"]:
        u = s.encode("utf-16le")
        idxs = [m.start() for m in re.finditer(re.escape(u), data)]
        print(f"utf16 {s!r} count={len(idxs)} first={idxs[:3]}")

    # Look for switch-like chains of message ids as consecutive bytes/words
    # Pattern: ... CB 00 00 00 CE 00 00 00 ... (203, 206)
    for m in re.finditer(rb"\xCB\x00\x00\x00\xCE\x00\x00\x00|\xCE\x00\x00\x00\xCB\x00\x00\x00", data):
        print("203/206 pair at", m.start(), data[m.start() - 16 : m.start() + 32].hex())

    # Byte immediate compare to 206: 80 F8 CE / 80 F9 CE / 3C CE / 41 80 F8 CE
    sites = [m.start() for m in re.finditer(rb"\x3C\xCE|\x80[\xF8\xF9\xFA\xFB]\xCE|\x41\x80[\xF8\xF9]\xCE|\x40\x80[\xF8\xF9]\xCE", data)]
    print("byte-cmp 206 sites", len(sites), sites[:40])

    # Word imm 206
    sites_w = [m.start() for m in re.finditer(rb"\x66\x3D\xCE\x00|\x66\x81.\xCE\x00|\x81.\xCE\x00\x00\x00", data)]
    print("word/dword cmp*206", len(sites_w), sites_w[:40])

    # Find code that references payload offsets 0..5 then calls - hard.
    # Alternative: dump Base_sensorDlg nearby for sat formatting "%1" patterns
    for needle in [b"%1", b"%1(%2)", b"sats", b"satellite", b"Sat"]:
        # too noisy
        pass

    # Chinese UI uses setText with QString::number for sat count.
    # Search for method names in moc: displayGps1data implementation is a slot.
    # The SLOT receives (int fix, int sats) — emitter is MAVLink parser.

    # Look near requestAllStreamDataSlot string for stream IDs
    off = data.find(b"requestAllStreamDataSlot")
    print("requestAll context", data[off : off + 200])

    # Search for proprietary crc extras near 215 (206 crc) and 61 (203 crc)
    for crc, name in [(215, "206crc"), (61, "203crc"), (87, "124crc")]:
        print(name, "le32 count", data.count(struct.pack("<I", crc)))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
