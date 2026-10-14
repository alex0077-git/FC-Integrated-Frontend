"""Merge remaining UI strings from the extract into app_en.arb (skip existing keys)."""
import json
import pathlib

base = pathlib.Path(__file__).resolve().parents[1] / "lib" / "l10n"
en_path = base / "app_en.arb"
en = json.loads(en_path.read_text(encoding="utf-8"))

# New keys from extract (values only; @meta added where needed).
additions = {
    "close": "Close",
    "delete": "Delete",
    "ok": "OK",
    "retry": "Retry",
    "mapAttributionEsri": "Tiles © Esri (imagery + place labels)",
    "mapAttributionOsm": "© OpenStreetMap contributors",
    "digitalSkyEmbedBlocked": "Digital Sky will not open inside this app. Their site blocks other websites from showing the map.",
    "digitalSkyDidNotLoad": "Digital Sky did not load",
    "openDigitalSky": "Open Digital Sky",
    "openDigitalSkyInBrowser": "Open Digital Sky in browser",
    "calibrationRadio": "Radio",
    "calibrationImu": "IMU",
    "calibrationCompass": "Compass",
    "calibrationStatusCalibrating": "Calibrating...",
    "calibrationStatusCalibrated": "Calibrated",
    "calibrationStatusNotCalibrated": "Not calibrated",
    "startCalibrationFull": "Start Calibration",
    "connectLiveLink": "Live link: {link}",
    "connectUsbIntro": "USB for ground setup. For flying, connect the app to the transmitter over Bluetooth or WiFi — commands go App → TX → aircraft.",
    "connectWebUnsupported": "This web build cannot open USB, Bluetooth, or WiFi sockets. Run the Windows or Android app.",
    "transmitterPickHint": "Pick Bluetooth or WiFi depending on your transmitter. USB above is unchanged for ground setup.",
    "btAbbrev": "BT",
    "transmitterIpHost": "Transmitter IP / host",
    "tcpPort": "TCP port",
    "remoteUdpPort": "Remote UDP port",
    "localUdpPort": "Local UDP port",
    "tryingWifiPorts": "Trying ports…",
    "autoTryWifiPorts": "Auto-try WiFi ports",
    "loadingParameters": "Loading parameters {received}/{total}",
    "linkLostTransmitter": "Link lost — check transmitter power, Bluetooth/WiFi, and range.",
    "linkLostUsb": "Link lost — check the USB cable and FC power.",
    "connectLiveHint": "USB: plug into the FC on the ground. Flying: connect this app to the transmitter (Bluetooth or WiFi); commands and telemetry go through the TX to the aircraft. Keep the RC sticks for manual override.",
    "connectErrorUsbNeedsNative": "Live K++ USB needs the Windows or Android build — web cannot open serial ports.",
    "connectErrorNoComPort": "No COM port found. Plug the K++ USB data cable in and refresh.",
    "connectErrorInvalidPort": "Enter a valid {label} (1–65535).",
    "connectErrorBluetoothNeedsNative": "Bluetooth needs the Windows or Android desktop/mobile build.",
    "connectErrorNoBluetoothSerial": "No Bluetooth serial port found. Pair the transmitter in system Bluetooth settings, then tap Refresh. If it still missing, enable “Show all COM ports”.",
    "connectErrorWifiNeedsNative": "Transmitter WiFi needs the Windows or Android build.",
    "connectErrorEnterTxHost": "Enter the transmitter WiFi IP / hostname.",
    "connectErrorNoWifiGateway": "No WiFi gateway found. Join the transmitter WiFi first.",
    "connectUsingGateway": "Using gateway {gateway} — tap Connect transmitter (WiFi).",
    "connectWifiJoinFirst": "Join transmitter WiFi first, then try again.",
    "connectWifiTcpSuccess": "Connected over TX WiFi TCP {host}:{port}",
    "connectWifiG20Success": "Connected to Skydroid G20 TCP 192.168.43.1:5760",
    "connectWifiUdpListenSuccess": "Listening UDP 14550 — power the TX/aircraft so it sends telemetry.",
    "connectWifiAutoTryFailed": "WiFi auto-try failed.\n{detail}\n\nFor Skydroid G20: WiFi mode = TCP, IP 192.168.43.1, port 5760. On the G20 turn on WLAN hotspot and data-transmission sharing; aircraft + GR01 must be linked (baud match on FC telem port).",
    "rtlCommandConfirm": "Command the live drone to return to launch?",
    "connectUsbToKppFirst": "Connect USB to K++ first",
    "noFlyZone": "No-Fly Zone",
    "orientation": "Orientation",
    "autoAlign": "Auto-align",
    "edgeMargin": "Edge margin",
    "operationMode": "Operation Mode",
    "sprayOn": "Spray on",
    "sprayOff": "Spray off",
    "latitude": "Latitude",
    "longitude": "Longitude",
    "action": "Action",
    "selectCrop": "Select Crop",
    "sprayRate": "Spray Rate",
    "notes": "Notes",
    "name": "Name",
    "defaultMissionName": "Mission",
    "uploadFlyConfirmMessage": "Upload {count} waypoints to the live K++, arm if needed, and start Auto (takeoff {meters} m)?",
    "missionUploadedSuccess": "Mission uploaded — saved locally and Auto started on live K++",
    "missionSavedToDatabase": "Mission saved to database",
    "noSavedMissions": "No saved missions",
    "connectKppUsbFirst": "Connect a live K++ over USB first",
    "enterMeterVoltageInMaxVoltage": "Enter a meter voltage in Max Voltage",
    "battVoltMultWritten": "BATT_VOLT_MULT written to live K++",
    "savedLocallyFcSyncFailed": "Saved locally; FC sync failed: {error}",
    "mapHintTapPlacePointA": "Tap the map to place point A",
    "mapHintTapPlacePointB": "Tap the map to place point B",
    "mapHintTapBoundaryForSplit": "Tap the boundary for the selected point",
    "mapHintTapAddBoundaryPoint": "Tap the map to add a boundary point",
    "splitChoosePointsHint": "Choose First Point or End Point, then tap a boundary point or anywhere along the boundary.",
    "chooseCircleOrPolygon": "Choose Circle or Polygon",
    "tapInsideFieldPlaceCircle": "Tap inside the field to place the circle.",
    "tapMapPlaceCornersInOrder": "Tap the map to place each corner, in order.",
}

meta = {
    "connectLiveLink": {"placeholders": {"link": {"type": "String"}}},
    "loadingParameters": {
        "placeholders": {
            "received": {"type": "int"},
            "total": {"type": "int"},
        }
    },
    "connectErrorInvalidPort": {"placeholders": {"label": {"type": "String"}}},
    "connectUsingGateway": {"placeholders": {"gateway": {"type": "String"}}},
    "connectWifiTcpSuccess": {
        "placeholders": {"host": {"type": "String"}, "port": {"type": "String"}}
    },
    "connectWifiAutoTryFailed": {"placeholders": {"detail": {"type": "String"}}},
    "uploadFlyConfirmMessage": {
        "placeholders": {"count": {"type": "int"}, "meters": {"type": "String"}}
    },
    "savedLocallyFcSyncFailed": {"placeholders": {"error": {"type": "String"}}},
}

added = 0
for k, v in additions.items():
    if k not in en:
        en[k] = v
        if k in meta:
            en[f"@{k}"] = meta[k]
        added += 1

en_path.write_text(json.dumps(en, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"added {added} keys; total value keys={len([k for k in en if not k.startswith('@')])}")
