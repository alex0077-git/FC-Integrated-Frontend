#!/usr/bin/env python3
"""Convert a USBPcap/Wireshark .pcap of CH340 USB traffic into K++ GPS jsonl.

Works without com0com: connect the official assistant directly to COM3, capture
USB with USBPcap, then run this converter + analyze_kpp_capture.py.
"""

from __future__ import annotations

import argparse
import json
import struct
from datetime import datetime, timezone
from pathlib import Path

from kpp_mavlink_wire import GPS_FOCUS_IDS, FrameParser

try:
    from scapy.all import PcapReader  # type: ignore
except ImportError:
    raise SystemExit("Install scapy:  python -m pip install scapy") from None

# USBPcap header after PCAP packet header (see USBPcap docs)
# typedef struct {
#   u16 headerLen; u64 irpId; u32 status; u16 function; u8 info;
#   u16 bus; u16 device; u8 endpoint; u8 transfer; u32 dataLength;
# } USBPCAP_BUFFER_PACKET_HEADER;


def _usbpcap_payload(raw: bytes) -> tuple[str | None, bytes]:
    """Return (direction, payload) for bulk transfers; direction is fc|app|None."""
    if len(raw) < 27:
        return None, b""
    header_len = struct.unpack_from("<H", raw, 0)[0]
    if header_len < 27 or header_len > len(raw):
        return None, b""
    info = raw[15]
    endpoint = raw[21]
    transfer = raw[22]
    data_len = struct.unpack_from("<I", raw, 23)[0]
    data = raw[header_len : header_len + data_len]
    if not data:
        return None, b""
    # transfer: 0 control, 1 isoch, 2 bulk, 3 interrupt
    if transfer not in (2, 3, 0):
        # still try bulk-looking data
        pass
    # info bit0: 0 = from host (OUT / to device), 1 = from device (IN)
    from_device = bool(info & 0x01)
    # endpoint low 7 bits; IN endpoints usually have 0x80 set in address byte
    ep_in = bool(endpoint & 0x80)
    if from_device or ep_in:
        return "fc", data  # device -> host  (FC -> APP)
    return "app", data  # host -> device (APP -> FC)


def convert(pcap_path: Path, out_path: Path) -> tuple[int, int]:
    parsers = {"fc": FrameParser(), "app": FrameParser()}
    count = 0
    gps = 0
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as fp, PcapReader(str(pcap_path)) as reader:
        for pkt in reader:
            raw = bytes(pkt)
            # Some readers wrap; prefer pkt.load if present
            if hasattr(pkt, "load") and pkt.load:
                raw = bytes(pkt.load)
            direction, data = _usbpcap_payload(raw)
            if direction is None or not data:
                continue
            for frame in parsers[direction].feed(data):
                rec = {
                    "t": datetime.now(timezone.utc).isoformat(),
                    "dir": direction,
                    **frame,
                }
                fp.write(json.dumps(rec, separators=(",", ":")) + "\n")
                count += 1
                if frame["msgid"] in GPS_FOCUS_IDS:
                    gps += 1
    return count, gps


def main() -> int:
    ap = argparse.ArgumentParser(description="USBPcap .pcap -> K++ GPS jsonl")
    ap.add_argument("pcap", type=Path)
    ap.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Output jsonl (default: captures/<pcap_stem>_kpp.jsonl)",
    )
    args = ap.parse_args()
    out = args.out or (Path(__file__).resolve().parent / "captures" / f"{args.pcap.stem}_kpp.jsonl")
    n, g = convert(args.pcap, out)
    print(f"Wrote {n} frames ({g} GPS-focus) -> {out}")
    print(f"Next:  python analyze_kpp_capture.py \"{out}\"")
    return 0 if n else 2


if __name__ == "__main__":
    raise SystemExit(main())
