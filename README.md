# Fuselage

Unified ground-station app: **FC Frontend** (Start map, Ground Plan, job flow) plus embedded **Fuselage-K++** (USB/wireless MAVLink, tuning, mission GCS).

## Packages

| Path | Role |
|------|------|
| `fc_frontend_src/FC-Frontend-main` | Host Flutter app (run this) |
| `fuselage_kpp` | K++ link, telemetry, params, mission tools |

## Run

```bash
cd fc_frontend_src/FC-Frontend-main
flutter pub get
flutter run -d windows
```

Use the desktop (or Android) build for USB serial COM ports — not a browser tab.
