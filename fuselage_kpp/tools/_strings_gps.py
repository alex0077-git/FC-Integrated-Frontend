#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path


def main() -> int:
    data = Path(sys.argv[1]).read_bytes()
    cn = ["未连接", "正常", "异常", "卫星", "罗盘", "气压", "陀螺", "加速", "已连接", "无GPS", "搜星", "未插"]
    for enc in ("utf-8", "gbk", "gb2312"):
        try:
            text = data.decode(enc, errors="ignore")
        except Exception:
            continue
        for c in cn:
            idx = 0
            n = 0
            while n < 8:
                i = text.find(c, idx)
                if i < 0:
                    break
                frag = text[max(0, i - 24) : i + 48].replace("\n", " ")
                print(f"[{enc}] {frag!r}")
                idx = i + 1
                n += 1

    print("--- ascii GPS UI ---")
    asci = [s.decode("ascii", "ignore") for s in re.findall(rb"[\x20-\x7e]{5,100}", data)]
    keys = (
        "displayGps",
        "sendGps",
        "requestAll",
        "No Fix",
        "RTK",
        "GPS1",
        "GPS2",
        "satellite",
        "Normal",
        "connect",
        "Stream",
        "msgid",
        "MAV",
        "Not",
        "status",
    )
    for s in asci:
        if any(k in s for k in keys):
            if "QPushButton" in s or "http" in s or "combobox" in s or "border-image" in s:
                continue
            print(s)

    needle = b"displayGps1data"
    i = data.find(needle)
    print("displayGps1data offset", i)
    for val, name in [(203, "203"), (206, "206"), (24, "24"), (124, "124"), (33, "33"), (66, "66"), (211, "211"), (220, "220")]:
        print(f"byte {name} count={data.count(bytes([val]))}")

    # demangled-ish markers
    for n in (
        b"requestAllStreamDataSlot",
        b"signal_sendGps1Data",
        b"signal_sendGps2Data",
        b"openSerialConnected",
        b"KppGps",
        b"GPS_RAW",
        b"GLOBAL_POSITION",
    ):
        print(n.decode(), "at", data.find(n))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
