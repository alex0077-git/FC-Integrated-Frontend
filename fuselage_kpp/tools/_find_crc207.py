#!/usr/bin/env python3
from pathlib import Path

exe = next(Path(__file__).resolve().parents[2].rglob("JIYI221014.exe"))
data = exe.read_bytes()
i = 796032
dart = {
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
    65: 118,
    66: 148,
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
print("exe_size", exe.stat().st_size)
print("msgid dart vs table@%d" % i)
for mid, crc in sorted(dart.items()):
    t = data[i + mid]
    print("  %3d: dart=%3d table=%3d %s" % (mid, crc, t, "OK" if t == crc else "DIFF"))
print("207 table", data[i + 207])
print("204-210", list(data[i + 204 : i + 211]))

hits = []
for j in range(0, len(data) - 256):
    if data[j + 206] == 215 and data[j + 203] == 61 and data[j + 24] == 24 and data[j + 0] == 50:
        hits.append(j)
print("similar bases", hits)
for j in hits:
    print(j, "207=", data[j + 207], "147=", data[j + 147], "66=", data[j + 66], "124=", data[j + 124])
