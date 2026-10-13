import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Zoom used when auto-focusing Mission / Start maps on live GPS.
const mapGpsFocusZoom = 17.0;

/// Live FC / GPS-puck position from [telemetryProvider] (same as [LiveGpsMapLayers]).
LatLng? liveFcGpsPoint(WidgetRef ref) {
  final telemetry = ref.read(telemetryProvider);
  final lat = telemetry.latDeg;
  final lon = telemetry.lonDeg;
  if (lat == null || lon == null) {
    return null;
  }
  return LatLng(lat, lon);
}

/// One-shot device GPS when the FC has no lat/lon yet (same idea as the FC front page).
final deviceGpsProvider = FutureProvider<LatLng?>((ref) async {
  try {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      return null;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return LatLng(position.latitude, position.longitude);
  } catch (_) {
    return null;
  }
});

/// Moves a map to GPS once when the page opens (FC first, then device).
class MapGpsFocus {
  bool _applied = false;
  bool _deviceLookupStarted = false;

  bool get applied => _applied;

  void markApplied() => _applied = true;

  /// Allow a new snap after the map is remounted / session changes.
  void reset() {
    _applied = false;
    _deviceLookupStarted = false;
  }

  bool _mapReady(MapController controller) {
    try {
      controller.camera;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _move(MapController controller, LatLng point, double zoom) {
    if (!_mapReady(controller)) {
      return false;
    }
    try {
      controller.move(point, zoom);
      _applied = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Snap to FC GPS when available. No-op after the first successful move.
  bool tryFocusFc(
    WidgetRef ref,
    MapController controller, {
    double zoom = mapGpsFocusZoom,
  }) {
    if (_applied) {
      return false;
    }
    final point = liveFcGpsPoint(ref);
    if (point == null) {
      return false;
    }
    return _move(controller, point, zoom);
  }

  /// FC GPS if available; otherwise device GPS. Safe from [onMapReady] or a post-frame callback.
  Future<void> focusOnOpen(
    WidgetRef ref,
    MapController controller, {
    double zoom = mapGpsFocusZoom,
  }) async {
    if (_applied) {
      return;
    }
    if (tryFocusFc(ref, controller, zoom: zoom)) {
      return;
    }
    // Map may not be attached yet — retry next frame for FC GPS.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      tryFocusFc(ref, controller, zoom: zoom);
    });
    if (_applied || _deviceLookupStarted) {
      return;
    }
    _deviceLookupStarted = true;
    final device = await ref.read(deviceGpsProvider.future);
    if (_applied || device == null) {
      return;
    }
    // Prefer FC if it arrived while waiting for the device fix.
    if (tryFocusFc(ref, controller, zoom: zoom)) {
      return;
    }
    _move(controller, device, zoom);
  }
}
