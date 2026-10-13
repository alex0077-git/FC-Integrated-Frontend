import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/map/map_gps_focus.dart' as kpp_gps;
import 'package:fuselage_kpp/core/theme/app_theme.dart' as kpp_theme;
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';

export 'package:fuselage_kpp/core/map/map_gps_focus.dart'
    show liveFcGpsPoint, mapGpsFocusZoom, deviceGpsProvider;

/// Moves a map to GPS once when the page opens (FC first, then device).
class MapGpsFocus {
  final kpp_gps.MapGpsFocus _inner = kpp_gps.MapGpsFocus();

  bool get applied => _inner.applied;

  void markApplied() => _inner.markApplied();

  void reset() => _inner.reset();

  bool tryFocusFc(
    WidgetRef ref,
    MapController controller, {
    double zoom = kpp_gps.mapGpsFocusZoom,
  }) {
    return _inner.tryFocusFc(ref, controller, zoom: zoom);
  }

  Future<void> focusOnOpen(
    WidgetRef ref,
    MapController controller, {
    double zoom = kpp_gps.mapGpsFocusZoom,
  }) {
    return _inner.focusOnOpen(ref, controller, zoom: zoom);
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

    final device = ref.watch(kpp_gps.deviceGpsProvider).asData?.value;
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
