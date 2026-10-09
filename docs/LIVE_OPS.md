# Live ops: link, GPS, maps, Digital Sky

## Connection

- **USB serial** — ground setup to the K++ (Windows/Android desktop builds only).
- **Transmitter Bluetooth / WiFi** — airborne MAVLink path (e.g. Skydroid G20 TCP `192.168.43.1:5760`).

## GPS & compass status

GPS and compass rows show **Normal** only when the GPS puck looks live (fix/sats), not from stale lat/lon or SYS_STATUS present bits. Unplugged puck → **Not connected** for both.

## Maps

Start and Ground Plan reuse K++ `LiveGpsMapLayers` (accuracy ring + marker). On open they auto-focus FC GPS, then device GPS if needed.

## Digital Sky

Windows uses Edge WebView2 (`webview_flutter_windows`). If the runtime is missing, the UI offers opening the portal in the system browser. Digital Sky is the public AAI map — not tied to the FC simulator or USB link.
