"""Extract ParamCatalog labels/options/help into ARB keys and a Dart lookup."""
from __future__ import annotations

import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
catalog = (root / "lib/data/params/param_catalog.dart").read_text(encoding="utf-8")
l10n_dir = root / "lib/l10n"
en_path = l10n_dir / "app_en.arb"
en = json.loads(en_path.read_text(encoding="utf-8"))

# Shared option maps in catalog.
shared_opts = {
    "Forward": "optForward",
    "Right": "optRight",
    "Backward": "optBackward",
    "Left": "optLeft",
    "Off": "optOff",
    "On": "optOn",
    "Single pump": "optSinglePump",
    "Double pump": "optDoublePump",
    "Quad X": "optQuadX",
    "Quad +": "optQuadPlus",
    "Hexa X": "optHexaX",
    "Hexa +": "optHexaPlus",
    "Octo X": "optOctoX",
    "Octo +": "optOctoPlus",
    "Standard": "optStandard",
    "Coaxial": "optCoaxial",
    "Y6": "optY6",
}

# Shared help blobs.
shared_help = {
    "_basicGainHelp": (
        "helpBasicGain",
        "Range 0–200 %. Adapts the controller to the airframe.",
    ),
    "_controlGainHelp": (
        "helpControlGain",
        "Range 0–300 %. Higher = faster response; limited by the airframe's power.",
    ),
    "_modeHelp": (
        "helpMode",
        "K++ options include Manual job, AB execute, Route job, GPS speed, "
        "Side shift and Terrain follow. Value mapping not yet confirmed.",
    ),
    "_channelHelp": (
        "helpChannel",
        "Function assigned to this RC channel. Each function should be used once; "
        "check the channel monitor before changing.",
    ),
}

# Parse ParamSpec blocks roughly.
# Find id + label pairs.
id_label = re.findall(
    r"ParamSpec\(\s*id:\s*'([^']+)'\s*,\s*label:\s*'((?:\\'|[^'])*)'",
    catalog,
)
# Also multiline ParamSpec(id: 'X', label: 'Y'
id_label += re.findall(
    r"id:\s*'([^']+)'\s*,\s*\n\s*label:\s*'((?:\\'|[^'])*)'",
    catalog,
)
# Deduplicate preserving order
seen = set()
pairs = []
for i, lab in id_label:
    if i not in seen:
        seen.add(i)
        pairs.append((i, lab.replace("\\'", "'")))

print(f"Found {len(pairs)} params")

# Inline options maps: options: {1: 'Quad X', ...}
option_blocks = re.findall(r"options:\s*\{([^}]+)\}", catalog)
extra_opts = set()
for block in option_blocks:
    for m in re.findall(r"['\"]([^'\"]+)['\"]", block):
        if m not in shared_opts and not m.isdigit():
            extra_opts.add(m)

# Help strings that are inline
helps = re.findall(r"help:\s*'((?:\\'|[^'])*)'", catalog)
unique_helps = []
help_keys = {}
for h in helps:
    h = h.replace("\\'", "'")
    if h not in help_keys:
        key = f"help_{len(help_keys)}"
        help_keys[h] = key
        unique_helps.append((key, h))

# Page chrome keys (settings UI)
chrome = {
    "notConnected": "Not connected",
    "notConnectedHint": "Choose a COM port (or the simulator) in the bar above and press Connect.",
    "cardFrameType": "Frame type",
    "frameTypeSubtitle": "Same as K++ assistant: yellow arm = nose, M1–M8 = FC ports, red CW / blue CCW = propeller spin. Writes FRAME and SHAPE.",
    "cardImuGpsMounting": "IMU & GPS mounting",
    "installationDescription": "Choose directions to match how the modules are mounted, and enter their offsets from the airframe's centre of gravity in centimetres (blue zone negative, yellow zone positive).",
    "remoteControlDescription": "To make sure the failsafe is set correctly, switch the RC off after changing it and check that channels 1–4 jump to centre (about 1500) and channel 5 jumps to its failsafe position.",
    "cardRcSettingsFailsafe": "RC settings & failsafe",
    "stickCalibration": "Stick calibration",
    "stickCalibrationIdle": "Current endpoints are shown below. Start to recalibrate channels 1–4.",
    "stickCalibrationExtremes": "Push every stick to its maximum and minimum several times, then press Next.",
    "stickCalibrationCentre": "Release every stick to the centre, then press Capture centre.",
    "stickCalibrationReview": "Check the results, then save them to the flight controller.",
    "startCalibration": "Start calibration",
    "captureCentre": "Capture centre",
    "saveCalibration": "Save calibration",
    "next": "Next",
    "channel": "Channel",
    "min": "Min",
    "centre": "Centre",
    "max": "Max",
    "channelMonitor": "Channel monitor",
    "sensorsImuCompassSubtitle": "Raw sensor values from each IMU instance.",
    "cardImuCompass": "IMU & compass",
    "cardBarometer": "Barometer",
    "noBarometerData": "No barometer data",
    "imuLevelCalibration": "IMU level calibration",
    "imuLevelCalibrationSubtitle": "Place the flight controller face up and level, then calibrate.",
    "compassCalibration": "Compass calibration",
    "compassCalibrationSubtitle": "Rotate the aircraft level and clockwise, then nose-down and clockwise.",
    "cardGlobalFlightLimits": "Global flight limits & motor idle",
    "motorTest": "Motor test",
    "motorTestSubtitle": "Spins each motor individually to check order and direction.",
    "removePropellers": "Remove propellers",
    "startTest": "Start test",
    "cardBasicGains": "Basic gains",
    "cardControlGains": "Control gains",
    "cardSpeedSensitivity": "Speed & sensitivity",
    "cardVoltageRtlLanding": "Voltage, return home & landing",
    "voltageCalibration": "Voltage calibration",
    "voltageCalibrationSubtitle": "Enter the voltage measured with a meter so the FC reading matches it.",
    "meterVoltageV": "Meter voltage (V)",
    "calibrateVoltage": "Calibrate voltage",
    "cardPump": "Pump",
    "cardLevelSensorProtection": "Level sensor & protection",
    "cardAbJobSettings": "AB job settings",
    "cardAbJobProcedure": "AB job procedure",
    "fenceDescription": "Circle and altitude limits. Draw/adjust the circle from the Mission map, or set values here.",
    "cardQuickFence": "Quick fence",
    "fenceEnabled": "Fence is enabled",
    "fenceOff": "Fence is off",
    "enableAltitudeAndCircle": "Enable altitude + circle",
    "disableFence": "Disable fence",
    "cardHeightDistanceLimits": "Height & distance limits",
    "cardRtkAntenna": "RTK antenna",
    "rtkCurrentPositioning": "Current positioning: {fix}",
    "cardRadarVision4g": "Radar, vision & 4G module status",
    "channelsDescription": "Check the channel monitor to see which channels your RC uses before assigning functions.",
    "cardChannelFunctions": "Channel functions",
    "flightLogsDescription": "Downloaded logs are saved to Documents\\Fuselage-K++\\logs.",
    "refreshList": "Refresh list",
    "logsOnFlightController": "{count} logs on the flight controller",
    "parametersDescription": "{count} parameters read from the flight controller.",
    "parameterFiles": "Parameter files",
    "reloadFromFc": "Reload from FC",
    "searchByIdOrName": "Search by id or name",
    "parametersShown": "{count} shown",
    "paramColumnId": "Id",
    "paramColumnName": "Name",
    "paramColumnValue": "Value",
    "paramFormHint": "Type a value and press Enter to write it to the flight controller.",
    "paramNotReported": "Not reported by this flight controller",
    "paramUnknownOption": "Unknown ({value})",
    "enterNumber": "Enter a number",
    "writeToFlightControllerTitle": "Write to flight controller?",
    "write": "Write",
    "cardVersions": "Versions",
    "cardVersionsAuthorisation": "Versions & authorisation",
    "firmwareUpgrade": "Firmware upgrade",
    "firmwareUpgradeDescription": "Upload K++ V2 / KX / P3 firmware through the flight controller bootloader. Never remove the device while upgrading.",
    "upgradeFirmware": "Upgrade firmware",
    "factoryReset": "Factory reset",
    "factoryResetDescription": "Restore every parameter to the factory defaults.",
    "restoreFactorySettings": "Restore factory settings",
    "droneRegistration": "Drone registration",
    "droneRegistrationDescription": "Manufacturer name, aircraft model and aircraft number (网络备案).",
    "shape": "Shape",
    "validateMinimum": "Minimum is {value}",
    "validateMaximum": "Maximum is {value}",
    "validateChooseOption": "Choose one of the listed options",
    "instance": "Instance",
    "accelAxes": "Accel X / Y / Z",
    "gyroAxes": "Gyro X / Y / Z",
    "compassAxes": "Compass X / Y / Z",
    "comingSoon": "Coming soon",
}

# Merge chrome
for k, v in chrome.items():
    if k not in en:
        en[k] = v

# Shared option ARB keys
for eng, key in shared_opts.items():
    en[key] = eng

for eng in sorted(extra_opts):
    key = "opt_" + re.sub(r"[^A-Za-z0-9]+", "_", eng).strip("_")
    # camelCase-ish
    parts = key.split("_")
    key = parts[0] + "".join(p[:1].upper() + p[1:] for p in parts[1:] if p)
    if not key.startswith("opt"):
        key = "opt" + key[0].upper() + key[1:]
    shared_opts[eng] = key
    en[key] = eng

# Param labels: pLabel_FRAME
param_label_keys = {}
for pid, lab in pairs:
    key = "pLabel_" + re.sub(r"[^A-Za-z0-9]", "_", pid)
    param_label_keys[pid] = key
    en[key] = lab

# Shared help
for _const, (key, text) in shared_help.items():
    en[key] = text

# Inline helps (limit size - store mapping)
for key, text in unique_helps:
    en[key] = text

# Meta for placeholders
en["@rtkCurrentPositioning"] = {"placeholders": {"fix": {"type": "String"}}}
en["@logsOnFlightController"] = {"placeholders": {"count": {"type": "int"}}}
en["@parametersDescription"] = {"placeholders": {"count": {"type": "int"}}}
en["@parametersShown"] = {"placeholders": {"count": {"type": "int"}}}
en["@paramUnknownOption"] = {"placeholders": {"value": {"type": "String"}}}
en["@validateMinimum"] = {"placeholders": {"value": {"type": "String"}}}
en["@validateMaximum"] = {"placeholders": {"value": {"type": "String"}}}

en_path.write_text(json.dumps(en, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("en keys", len([k for k in en if not str(k).startswith("@")]))

# Write Dart lookup for param labels / options / help
dart_lines = [
    "// GENERATED by tool/extract_param_l10n.py — do not edit by hand.",
    "import 'package:fuselage_kpp/data/params/param_spec.dart';",
    "import 'package:fuselage_kpp/l10n/app_localizations.dart';",
    "",
    "abstract final class ParamL10n {",
    "  static String label(KppLocalizations l10n, ParamSpec spec) {",
    "    switch (spec.id) {",
]
for pid, key in param_label_keys.items():
    dart_lines.append(f"      case '{pid}': return l10n.{key};")
dart_lines += [
    "      default: return spec.label;",
    "    }",
    "  }",
    "",
    "  static String option(KppLocalizations l10n, String english) {",
    "    switch (english) {",
]
for eng, key in sorted(shared_opts.items(), key=lambda x: x[0]):
    esc = eng.replace("\\", "\\\\").replace("'", "\\'")
    dart_lines.append(f"      case '{esc}': return l10n.{key};")
dart_lines += [
    "      default: return english;",
    "    }",
    "  }",
    "",
    "  static String? help(KppLocalizations l10n, ParamSpec spec) {",
    "    if (spec.help == null) return null;",
    "    // Shared help blobs from ParamCatalog constants.",
    "    switch (spec.help!) {",
]
for _const, (key, text) in shared_help.items():
    esc = text.replace("\\", "\\\\").replace("'", "\\'")
    dart_lines.append(f"      case '{esc}': return l10n.{key};")
for key, text in unique_helps:
    esc = text.replace("\\", "\\\\").replace("'", "\\'")
    dart_lines.append(f"      case '{esc}': return l10n.{key};")
dart_lines += [
    "      default: return spec.help;",
    "    }",
    "  }",
    "}",
    "",
]
(root / "lib/l10n/param_l10n.dart").write_text("\n".join(dart_lines), encoding="utf-8")
print("Wrote param_l10n.dart", len(param_label_keys), "labels", len(shared_opts), "options")

# Dump new keys for translators (JSON map english->key for chrome+opts+labels)
Path(root / "tool/param_l10n_keys.json").write_text(
    json.dumps(
        {
            "param_labels": param_label_keys,
            "options": shared_opts,
            "helps": {v: k for k, v in help_keys.items()},
        },
        ensure_ascii=False,
        indent=2,
    ),
    encoding="utf-8",
)
