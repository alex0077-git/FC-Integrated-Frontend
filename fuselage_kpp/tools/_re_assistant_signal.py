#!/usr/bin/env python3
"""Find Base_sensorDlg signal label thresholds near Chinese GPS strings."""
from __future__ import annotations

import re
import struct
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    exe = next(root.rglob("JIYI221014.exe"))
    data = exe.read_bytes()

    markers = {
        "no_fix": data.find("(no fix)".encode()),
        "weak": data.find("(信号差)".encode("utf-8")),
        "good": data.find("(信号好)".encode("utf-8")),
        "high": data.find("(高精度)".encode("utf-8")),
    }
    print("string offsets", markers)

    # Find pointers to these strings (x86/x64 PE often stores VA).
    # Parse PE optional header for ImageBase.
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    magic = struct.unpack_from("<H", data, e_lfanew + 0x18)[0]
    if magic == 0x20B:  # PE32+
        image_base = struct.unpack_from("<Q", data, e_lfanew + 0x30)[0]
        print("PE32+ image_base", hex(image_base))
    else:
        image_base = struct.unpack_from("<I", data, e_lfanew + 0x34)[0]
        print("PE32 image_base", hex(image_base))

    # Section table for RVA->file
    nsec = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_size = struct.unpack_from("<H", data, e_lfanew + 20)[0]
    sec_off = e_lfanew + 24 + opt_size
    sections = []
    for i in range(nsec):
        o = sec_off + i * 40
        name = data[o : o + 8].split(b"\0", 1)[0].decode("ascii", "ignore")
        vsz, va, rsz, raw = struct.unpack_from("<IIII", data, o + 8)
        sections.append((name, va, vsz, raw, rsz))
        print(f"section {name} va={va:#x} raw={raw:#x}")

    def file_to_rva(file_off: int) -> int | None:
        for name, va, vsz, raw, rsz in sections:
            if raw <= file_off < raw + max(rsz, vsz):
                return va + (file_off - raw)
        return None

    def rva_to_file(rva: int) -> int | None:
        for name, va, vsz, raw, rsz in sections:
            if va <= rva < va + max(vsz, rsz):
                return raw + (rva - va)
        return None

    # Search for absolute VAs pointing at each string
    for label, foff in markers.items():
        rva = file_to_rva(foff)
        if rva is None:
            print(label, "no rva")
            continue
        va = image_base + rva
        print(f"{label} file={foff:#x} rva={rva:#x} va={va:#x}")
        # LE pointer
        if magic == 0x20B:
            pat = struct.pack("<Q", va)
        else:
            pat = struct.pack("<I", va)
        refs = [m.start() for m in re.finditer(re.escape(pat), data)]
        print(f"  abs refs {len(refs)}", refs[:10])
        # Also try RVA-only (relative)
        for ref in refs[:5]:
            window = data[max(0, ref - 48) : ref + 16]
            print(f"  ref@{ref:#x} prev48={window.hex()}")

    # Dump msgid handler table entry for 206 more fully — look for function pointers after index
    # Second table at 9573656
    for table_at in (9571724, 9573656):
        print(f"\n==== table @{table_at} ====")
        for i in range(0, 80, 20):
            vals = [struct.unpack_from("<I", data, table_at + i + d)[0] for d in range(0, 20, 4)]
            print(table_at + i, vals)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
