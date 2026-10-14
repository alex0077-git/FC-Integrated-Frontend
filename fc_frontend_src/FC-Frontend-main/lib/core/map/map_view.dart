import 'package:fc_frontend/core/theme/app_theme.dart';
import 'package:fc_frontend/l10n/app_localizations.dart';
import 'package:fc_frontend/core/widgets/digital_sky_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:latlong2/latlong.dart';

/// Where a map opens before a field or a drone position is known.
const defaultMapCenter = LatLng(12.9716, 77.5946);

/// Pan and zoom stay on. Rotation stays off on every planning map.
InteractionOptions mapGestureOptions() {
  return InteractionOptions(
    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
    cursorKeyboardRotationOptions: CursorKeyboardRotationOptions.disabled(),
  );
}

enum MapViewMode { street, satellite, digitalSky }

class MapViewController extends StateNotifier<MapViewMode> {
  MapViewController() : super(MapViewMode.street);

  void setMode(MapViewMode mode) {
    state = mode;
  }
}

final mapViewModeProvider =
    StateNotifierProvider<MapViewController, MapViewMode>(
      (ref) => MapViewController(),
    );

class MapTileLayer extends ConsumerWidget {
  const MapTileLayer({super.key});

  static const streetUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const satelliteUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  /// Place / boundary labels only — drawn on top of World Imagery (which has no names).
  static const satelliteLabelsUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final satellite = ref.watch(mapViewModeProvider) == MapViewMode.satellite;
    if (satellite) {
      return Stack(
        fit: StackFit.expand,
        children: [
          TileLayer(
            urlTemplate: satelliteUrl,
            userAgentPackageName: 'fc_frontend',
          ),
          TileLayer(
            urlTemplate: satelliteLabelsUrl,
            userAgentPackageName: 'fc_frontend',
          ),
        ],
      );
    }
    return TileLayer(
      urlTemplate: streetUrl,
      userAgentPackageName: 'fc_frontend',
    );
  }
}

IconData mapModeIcon(MapViewMode mode) {
  return switch (mode) {
    MapViewMode.street => Icons.map,
    MapViewMode.satellite => Icons.satellite_alt,
    MapViewMode.digitalSky => Icons.flight,
  };
}

class MapStyleButton extends ConsumerWidget {
  const MapStyleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(mapViewModeProvider);
    return Material(
      color: AppTheme.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      child: PopupMenuButton<MapViewMode>(
        tooltip: l10n.mapStyle,
        initialValue: mode,
        onSelected: (value) {
          ref.read(mapViewModeProvider.notifier).setMode(value);
        },
        icon: Icon(mapModeIcon(mode)),
        itemBuilder: (context) {
          return [
            PopupMenuItem(value: MapViewMode.street, child: Text(l10n.mapStreet)),
            PopupMenuItem(
              value: MapViewMode.satellite,
              child: Text(l10n.mapSatellite),
            ),
            PopupMenuItem(
              value: MapViewMode.digitalSky,
              child: Row(
                children: [
                  const Icon(Icons.flight, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.mapDigitalSky),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }
}

/// Shows either the Flutter map or Digital Sky, with [overlays] kept on top.
///
/// Digital Sky is created the first time it is selected and then kept alive,
/// so its place and zoom survive switching back to Street or Satellite.
/// The hidden map is offstage and does not receive pan or zoom gestures.
class MapModeStack extends ConsumerStatefulWidget {
  const MapModeStack({super.key, required this.map, this.overlays = const []});

  final Widget map;
  final List<Widget> overlays;

  @override
  ConsumerState<MapModeStack> createState() => _MapModeStackState();
}

class _MapModeStackState extends ConsumerState<MapModeStack> {
  var _digitalSkyMounted = false;

  @override
  Widget build(BuildContext context) {
    final showSky = ref.watch(mapViewModeProvider) == MapViewMode.digitalSky;
    if (showSky) {
      _digitalSkyMounted = true;
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        IndexedStack(
          index: showSky ? 1 : 0,
          sizing: StackFit.expand,
          children: [
            widget.map,
            _digitalSkyMounted
                ? const DigitalSkyView()
                : const SizedBox.shrink(),
          ],
        ),
        ...widget.overlays,
      ],
    );
  }
}

class MapStyleToggle extends StatelessWidget {
  const MapStyleToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.bottomLeft,
      child: Padding(padding: EdgeInsets.all(12), child: MapStyleButton()),
    );
  }
}
