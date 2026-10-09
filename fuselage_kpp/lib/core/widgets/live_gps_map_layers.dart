import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:latlong2/latlong.dart';

/// Live GPS vehicle marker + position circle — shared by Mission, Map/Fly, and Ground Plan.
///
/// Uses the same [telemetryProvider] / fence params as the K++ Mission map:
/// - accuracy ring from HDOP (or 5 m default)
/// - geofence circle when `FENCE_ENABLE` is on
/// - navigation marker at the live lat/lon
class LiveGpsMapLayers extends ConsumerWidget {
  const LiveGpsMapLayers({
    super.key,
    this.rotateWithHeading = false,
    this.markerColor = Colors.deepPurple,
  });

  /// When true, rotate the marker by telemetry heading (fly map).
  final bool rotateWithHeading;
  final Color markerColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(telemetryProvider);
    final lat = telemetry.latDeg;
    final lon = telemetry.lonDeg;
    if (lat == null || lon == null) {
      return const SizedBox.shrink();
    }

    final point = LatLng(lat, lon);
    final fenceOn =
        (ref.watch(paramValuesProvider.select((p) => p['FENCE_ENABLE'] ?? 0))) > 0;
    final fenceRadius =
        (ref.watch(paramValuesProvider.select((p) => p['FENCE_RADIUS'] ?? 0))).toDouble();
    final hdop = telemetry.hdop;
    final accuracyMeters = hdop == null ? 5.0 : (hdop * 2.5).clamp(2.5, 50.0);

    final primary = Theme.of(context).colorScheme.primary;
    final circles = <CircleMarker>[
      CircleMarker(
        point: point,
        radius: accuracyMeters,
        useRadiusInMeter: true,
        color: primary.withValues(alpha: 0.14),
        borderStrokeWidth: 2,
        borderColor: primary.withValues(alpha: 0.75),
      ),
      if (fenceOn && fenceRadius > 0)
        CircleMarker(
          point: point,
          radius: fenceRadius,
          useRadiusInMeter: true,
          color: Colors.orange.withValues(alpha: 0.15),
          borderStrokeWidth: 2,
          borderColor: Colors.orange,
        ),
    ];

    final heading = telemetry.headingDeg ?? 0;
    return Stack(
      fit: StackFit.expand,
      children: [
        CircleLayer(circles: circles),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 40,
              height: 40,
              child: rotateWithHeading
                  ? Transform.rotate(
                      angle: heading * math.pi / 180,
                      child: Icon(Icons.navigation, color: markerColor, size: 36),
                    )
                  : Icon(Icons.navigation, color: markerColor, size: 36),
            ),
          ],
        ),
      ],
    );
  }
}
