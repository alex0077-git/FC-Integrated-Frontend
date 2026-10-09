import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/theme/app_theme.dart' as kpp_theme;
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Zoom used when auto-focusing Start / Ground Plan maps on GPS.
const mapGpsFocusZoom = 17.0;

/// Live FC / GPS-puck position from the same telemetry as K++ [LiveGpsMapLayers].
LatLng? liveFcGpsPoint(WidgetRef ref) {
  final telemetry = ref.read(telemetryProvider);
  final lat = telemetry.latDeg;
  final lon = telemetry.lonDeg;
  if (lat == null || lon == null) {
    return null;
  }
  return LatLng(lat, lon);
}

/// One-shot device GPS fix for map focus when FC has no position yet.
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

  bool get applied => _applied;

  void markApplied() => _applied = true;

  /// Prefer live FC GPS so the camera matches [LiveGpsMapLayers].
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
    controller.move(point, zoom);
    _applied = true;
    return true;
  }

  /// FC GPS if available; otherwise device GPS. Safe to call from [onMapReady].
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
    final device = await ref.read(deviceGpsProvider.future);
    if (_applied || device == null) {
      return;
    }
    controller.move(device, zoom);
    _applied = true;
  }
}

/// Accuracy ring + marker for tablet/phone GPS when FC has no lat/lon yet.
///
/// Hidden once K++ telemetry has a position so [LiveGpsMapLayers] is the sole
/// vehicle indicator (same look as Mission).
class DeviceGpsMapLayers extends ConsumerWidget {
  const DeviceGpsMapLayers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(telemetryProvider);
    if (telemetry.latDeg != null && telemetry.lonDeg != null) {
      return const SizedBox.shrink();
    }

    final device = ref.watch(deviceGpsProvider).asData?.value;
    if (device == null) {
      return const SizedBox.shrink();
    }

    final primary = Theme.of(context).colorScheme.primary;
    return Stack(
      fit: StackFit.expand,
      children: [
        CircleLayer(
          circles: [
            CircleMarker(
              point: device,
              radius: 5,
              useRadiusInMeter: true,
              color: primary.withValues(alpha: 0.14),
              borderStrokeWidth: 2,
              borderColor: primary.withValues(alpha: 0.75),
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: device,
              width: 40,
              height: 40,
              child: Icon(
                Icons.navigation,
                color: kpp_theme.AppTheme.primary,
                size: 36,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
