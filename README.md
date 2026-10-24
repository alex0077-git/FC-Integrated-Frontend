# Fuselage

A unified ground-control station for JIYI K++ agricultural drones — plan spray jobs on a live map, tune the flight controller like the original assistant, and fly Auto missions over USB or Skydroid Bluetooth — built as a Flutter host app with an embedded Fuselage-K++ MAVLink session layer.

## Why I built this

The stock JIYI tuning tool lives on Windows and is separate from day-to-day field flying. I wanted one app that could connect to a real K++ the same way the agri path does (USB COM or T12 Bluetooth), show honest live telemetry, plan a coverage mission, and command the aircraft — without inventing GPS, battery, or spray data. Fuselage combines the FC Frontend job flow with a reverse-engineered K++ link so phone and desktop can share one session.

## Features

- **Connect** — USB serial, Windows/Android Bluetooth SPP (Skydroid T12), and WiFi TCP/UDP presets for Skydroid G20-style links. Live K++ only for arm, land, and mission upload (simulator rejected for flying).
- **Start map** — Live FC GPS, mode, speed, altitude, flow/liquid tiles when reported, and battery charge of the attached pack (FC % or voltage-based SoC).
- **Ground Plan** — Draw boundaries, generate coverage waypoints, set spray on/off on segments, then **Upload & fly** with an optional takeoff/spray altitude checkbox.
- **Flight commands** — Arm / Disarm, Takeoff, RTL, Land from the app. Arm works from the GCS and still works from the transmitter in parallel.
- **Battery safety** — First and second warning thresholds; on second warning while armed, the app commands RTL automatically.
- **K++ Tuning** — Embedded Fuselage-K++ screens for sensors, gains, pump, liquid/flow meter ports, AB spraying, fence, protection, channels, logs, and firmware-oriented tools.
- **Localization** — UI strings for English, Arabic, German, Spanish, and Hindi.

## Tech Stack

**Host app (`fc_frontend`)**
- Flutter / Dart
- Riverpod (state)
- go_router (navigation)
- flutter_map (maps)
- Multilingual ARB / gen-l10n

**K++ session (`fuselage_kpp`)**
- Custom MAVLink codec (K++ obfuscated A1 wire + clear MAVLink-1 for WiFi)
- USB serial, Bluetooth SPP (Windows COM + Android RFCOMM), TCP/UDP links
- Parameter catalog mirroring JIYI assistant groupings
- Mission upload (`MISSION_ITEM_INT`) and command service (arm, modes, RTL/Land)

## Project Structure

```
Latest tuning software-20221014/
├── README.md
├── fc_frontend_src/FC-Frontend-main/     # Host Flutter app — run this
│   ├── lib/
│   │   ├── core/widgets/               # Connect panel, flight bars, status
│   │   ├── data/
│   │   │   ├── kpp/                    # Telemetry mapper, mission upload, param sync
│   │   │   ├── models/                 # Waypoints, battery, telemetry
│   │   │   └── repositories/           # Mission, flight commands, settings
│   │   └── features/
│   │       ├── ground_plan/            # Field planning + Upload & fly
│   │       ├── map_flight/             # Start map + battery RTL
│   │       └── settings/               # Battery thresholds, cells, etc.
│   └── android/                        # Android BT SPP bridge (Kotlin)
└── fuselage_kpp/                       # Embedded K++ MAVLink / tuning package
    ├── lib/data/
    │   ├── link/                       # USB, BT, WiFi, simulator
    │   ├── mavlink/                    # Codec + message types
    │   ├── params/                     # Param catalog
    │   └── session/                    # FC session, commands, telem, spray decode
    └── lib/features/                   # Overview, sensors, pump, liquid, spraying…
```

## How It Works

1. **Link** → Open Connect, pick USB COM or a paired T12 Bluetooth device. The session speaks the same K++ A1 framing as the Windows agri/Outgoing BT path, downloads parameters, and streams heartbeat / GPS / voltage.
2. **Plan** → On Ground Plan, set the field boundary and coverage. Upload & fly builds a Mission Planner–style mission (home → takeoff → path → RTL), optionally applying a takeoff altitude you set in the dialog.
3. **Arm & Auto** → The app tries GCS arm (cmd 400, SET_MODE, RC override holds). The transmitter stick-arm still works; after app arm attempts, RC override is released so both paths stay usable. Auto still uses the Mode-23 switch slot rewritten to Auto on many K++ builds.
4. **Fly safely** → Battery % tracks the attached pack. Cross the second warning while armed and the Start map path commands RTL. Spray pump behavior during Auto still follows FC/RC pump setup; flow/liquid HUD updates when the FC reports those values.

## Setup

### Prerequisites

- Flutter SDK (see `fc_frontend_src/FC-Frontend-main/pubspec.yaml` for SDK constraint)
- Windows for USB COM development, or Android for phone + T12 Bluetooth
- A real JIYI K++ (and Skydroid T12 if using BT) — web builds cannot open USB/BT

### Run (desktop)

```bash
cd fc_frontend_src/FC-Frontend-main
flutter pub get
flutter run -d windows
```

### Run (Android)

```bash
cd fc_frontend_src/FC-Frontend-main
flutter pub get
flutter run -d <your-android-device>
```

Pair the correct T12 in phone Bluetooth settings before Connect. Prefer the same TX that already works with your laptop agri path.

### Release APK (example)

```bash
cd fc_frontend_src/FC-Frontend-main
flutter build apk --release
```

Version in tree: **1.0.3+4** (see `pubspec.yaml`).

## Field notes

- Use **Good GPS** (≥6 sats) before arm / Upload & fly.
- Set **Settings → Battery** cell count (and max/min V) for your pack so charge % matches the attached battery.
- Pump spray on/off on the map is planning guidance; confirm pump type and channels in K++ Tuning for real spray.
- Flow meter goes on FC port **K1**; live L/min appears when the FC reports it.

## What I Learned

This work went past a thin UI wrapper: decoding K++ proprietary GPS/status frames, matching Windows BT COM behavior on Android SPP, separating radio-status-only pipes from real FC A1 traffic, and building flight commands that survive firmware quirks (cmd 400 unsupported, NAV_RTL falling back to SET_MODE). It also forced honest telemetry (no fake GPS or battery %), dual arm (app + TX), and battery-driven RTL — the difference between a demo GCS and something you can take to a spray field.
