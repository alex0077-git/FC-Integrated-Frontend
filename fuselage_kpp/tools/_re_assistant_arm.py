#!/usr/bin/env python3
"""Find how JIYI221014 arms / unlocks the FC."""
from __future__ import annotations

import re
import struct
from pathlib import Path


def main() -> int:
    exe = next(Path(__file__).resolve().parents[2].rglob("JIYI221014.exe"))
    data = exe.read_bytes()
    print("size", exe.stat().st_size)

    for s in ["解锁", "上锁", "加锁", "开锁", "Arm", "Disarm", "arm", "unlock"]:
        for enc_name, enc in [("utf16", "utf-16le"), ("utf8", "utf-8")]:
            try:
                needle = s.encode(enc)
            except UnicodeEncodeError:
                continue
            idxs = [m.start() for m in re.finditer(re.escape(needle), data)]
            if idxs:
                print(enc_name, "str_len", len(s), "count", len(idxs), "at", idxs[:5])

    # COMMAND_LONG id 76 near 400
    for pat, name in [
        (struct.pack("<H", 400), "u16_400"),
        (struct.pack("<I", 400), "u32_400"),
        (bytes([0x90, 0x01]), "bytes_400"),
    ]:
        print(name, data.count(pat))

    # Proprietary msg ids we know: 211 setup, 220 ready — look for neighbors
    for mid in (211, 220, 212, 213, 221, 222, 223):
        print("msgid", mid, "le32 count", data.count(struct.pack("<I", mid)))

    # Strings that look like unlock slots
    for needle in [
        b"unlock",
        b"Unlock",
        b"ARM",
        b"armFC",
        b"arm_fc",
        b"doArm",
        b"setArm",
        b"motorOn",
        b"MotorOn",
        b"signal_send",
    ]:
        i = data.find(needle)
        print(needle, i)

    # Dump ascii around 'unlock' case-insensitive
    for m in re.finditer(rb"(?i)unlock|arming|disarm", data):
        start = max(0, m.start() - 40)
        chunk = data[start : m.end() + 40]
        ascii_bits = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
        print("ctx", m.start(), ascii_bits)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
