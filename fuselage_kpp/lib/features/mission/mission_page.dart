import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/live_gps_map_layers.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/mission/mission_item.dart';
import 'package:fuselage_kpp/data/mission/waypoint_file.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/data/repositories/mission_repository.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';
import 'package:latlong2/latlong.dart';

/// Mission Planner–style map GCS: HUD, waypoints, AB spray, fence circle, modes.
class MissionPage extends ConsumerStatefulWidget {
  const MissionPage({super.key});

  @override
  ConsumerState<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends ConsumerState<MissionPage> {
  final _mapController = MapController();
  double _defaultAlt = 20;
  LatLng? _pointA;
  LatLng? _pointB;
  bool _placingFence = false;
  bool _busy = false;
  String? _message;

  LatLng get _center {
    final t = ref.read(telemetryProvider);
    if (t.latDeg != null && t.lonDeg != null) {
      return LatLng(t.latDeg!, t.lonDeg!);
    }
    return const LatLng(12.9716, 77.5946);
  }

  Future<void> _run(Future<void> Function() action, String ok) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      setState(() => _message = ok);
    } catch (error) {
      setState(() => _message = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _onMapTap(TapPosition _, LatLng point) {
    if (_placingFence) {
      _setCircleFence(point);
      return;
    }
    final items = ref.read(missionProvider);
    ref.read(missionProvider.notifier).add(
      MissionItem(
        seq: items.length,
        command: items.isEmpty ? MavCmd.navTakeoff : MavCmd.navWaypoint,
        frame: MavFrame.globalRelativeAltInt,
        lat: point.latitude,
        lon: point.longitude,
        alt: _defaultAlt,
      ),
    );
  }

  Future<void> _setCircleFence(LatLng center) async {
    setState(() => _placingFence = false);
    final radius = ref.read(paramValuesProvider)['FENCE_RADIUS'] ?? 500;
    await writeParamsFromUi(
      context,
      ref,
      values: {
        'FENCE_ENABLE': 1,
        'FENCE_TYPE': 2,
        'FENCE_RADIUS': radius,
      },
    );
    // Store centre as first WP if empty — visual only uses vehicle/home; radius from params.
    setState(() => _message = 'Circle fence enabled, radius ${radius.round()} m (centred on aircraft when flying)');
  }

  Future<void> _generateAb() async {
    final a = _pointA;
    final b = _pointB;
    if (a == null || b == null) {
      setState(() => _message = 'Set points A and B on the map first');
      return;
    }
    final params = ref.read(paramValuesProvider);
    final swath = params['ABPOINT_DIS'] ?? 5;
    final speed = params['ABPOINT_SPEED'] ?? 5;
    final mission = generateAbSprayMission(
      latA: a.latitude,
      lonA: a.longitude,
      latB: b.latitude,
      lonB: b.longitude,
      swathMeters: swath,
      altitude: _defaultAlt,
      speedMps: speed,
    );
    ref.read(missionProvider.notifier).replace(mission);
    await writeParamsFromUi(context, ref, values: {'ABPOINT_DIS': swath, 'ABPOINT_SPEED': speed});
    setState(() => _message = 'AB spray pattern generated (${mission.length} items)');
  }

  Future<void> _exportWaypoints() async {
    final text = WaypointFile.encode(ref.read(missionProvider));
    final path = await getSaveLocation(suggestedName: 'mission.waypoints');
    if (path == null) {
      return;
    }
    await File(path.path).writeAsString(text);
    setState(() => _message = 'Exported ${path.path}');
  }

  Future<void> _importWaypoints() async {
    final file = await openFile(acceptedTypeGroups: [const XTypeGroup(label: 'waypoints', extensions: ['waypoints', 'txt'])]);
    if (file == null) {
      return;
    }
    final text = await file.readAsString();
    ref.read(missionProvider.notifier).replace(WaypointFile.decode(text));
    setState(() => _message = 'Imported ${ref.read(missionProvider).length} items');
  }

  @override
  Widget build(BuildContext context) {
    final mission = ref.watch(missionProvider);
    final telemetry = ref.watch(telemetryProvider);

    return RequiresConnection(
      child: Column(
        children: [
          _HudBar(
            telemetry: telemetry,
            busy: _busy,
            onRtl: () => _run(() => ref.read(fcSessionProvider)!.commands.returnToLaunch(), 'RTL accepted'),
            onLand: () => _run(() => ref.read(fcSessionProvider)!.commands.land(), 'Land accepted'),
            onMode: (mode) => _run(() => ref.read(fcSessionProvider)!.commands.setMode(mode), 'Mode $mode set'),
          ),
          if (_message != null)
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(_message!)),
                    IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => _message = null)),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 17,
                      onTap: _onMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.fuselage.kpp',
                      ),
                      const LiveGpsMapLayers(),
                      PolylineLayer(
                        polylines: [
                          if (mission.length >= 2)
                            Polyline(
                              points: [
                                for (final item in mission)
                                  if (item.lat != 0 || item.lon != 0) LatLng(item.lat, item.lon),
                              ],
                              strokeWidth: 3,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          for (final item in mission)
                            if (item.lat != 0 || item.lon != 0)
                              Marker(
                                point: LatLng(item.lat, item.lon),
                                width: 36,
                                height: 36,
                                child: Tooltip(
                                  message: '${item.seq}: ${item.commandLabel}',
                                  child: CircleAvatar(
                                    radius: 14,
                                    child: Text('${item.seq}', style: const TextStyle(fontSize: 11)),
                                  ),
                                ),
                              ),
                          if (_pointA != null)
                            Marker(
                              point: _pointA!,
                              width: 40,
                              height: 40,
                              child: const CircleAvatar(backgroundColor: Colors.green, child: Text('A')),
                            ),
                          if (_pointB != null)
                            Marker(
                              point: _pointB!,
                              width: 40,
                              height: 40,
                              child: const CircleAvatar(backgroundColor: Colors.red, child: Text('B')),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 340,
                  child: Material(
                    elevation: 2,
                    child: _MissionSidePanel(
                      mission: mission,
                      defaultAlt: _defaultAlt,
                      placingFence: _placingFence,
                      busy: _busy,
                      onAltChanged: (v) => setState(() => _defaultAlt = v),
                      onDownload: () => _run(() => ref.read(missionProvider.notifier).download(), 'Mission downloaded'),
                      onUpload: () => _run(() => ref.read(missionProvider.notifier).upload(), 'Mission uploaded'),
                      onClear: () => _run(() => ref.read(missionProvider.notifier).clearRemote(), 'Mission cleared'),
                      onImport: _importWaypoints,
                      onExport: _exportWaypoints,
                      onSetA: () => setState(() {
                        final t = ref.read(telemetryProvider);
                        _pointA = t.latDeg != null ? LatLng(t.latDeg!, t.lonDeg!) : _mapController.camera.center;
                      }),
                      onSetB: () => setState(() {
                        final t = ref.read(telemetryProvider);
                        _pointB = t.latDeg != null ? LatLng(t.latDeg!, t.lonDeg!) : _mapController.camera.center;
                      }),
                      onGenerateAb: _generateAb,
                      onToggleFence: () => setState(() => _placingFence = !_placingFence),
                      onRemove: (i) => ref.read(missionProvider.notifier).removeAt(i),
                      onEditAlt: (i, alt) {
                        final item = mission[i];
                        ref.read(missionProvider.notifier).updateAt(i, item.copyWith(alt: alt));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HudBar extends StatelessWidget {
  const _HudBar({
    required this.telemetry,
    required this.busy,
    required this.onRtl,
    required this.onLand,
    required this.onMode,
  });

  final FcTelemetry telemetry;
  final bool busy;
  final VoidCallback onRtl;
  final VoidCallback onLand;
  final void Function(int mode) onMode;

  @override
  Widget build(BuildContext context) {
    String modeLabel() {
      final m = telemetry.customMode;
      return switch (m) {
        null => '—',
        0 => 'Stabilize',
        2 => 'AltHold',
        3 => 'Auto',
        4 => 'Guided',
        5 => 'Loiter',
        6 => 'RTL',
        9 => 'Land',
        _ => 'Mode $m',
      };
    }

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Flexible(
              child: Text(
                '${telemetry.armed ? 'ARMED' : 'Disarmed'}  ·  $modeLabel()  ·  '
                'GPS ${telemetry.gpsFixLabel} (${telemetry.satellites ?? '—'} sats)  ·  '
                '${telemetry.voltage == null ? '— V' : '${telemetry.voltage!.toStringAsFixed(1)} V'}  ·  '
                'Alt ${telemetry.altMeters == null ? '—' : '${telemetry.altMeters!.toStringAsFixed(1)} m'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Spacer(),
            DropdownButton<int>(
              hint: const Text('Set mode'),
              items: const [
                DropdownMenuItem(value: 3, child: Text('Auto')),
                DropdownMenuItem(value: 4, child: Text('Guided')),
                DropdownMenuItem(value: 5, child: Text('Loiter')),
                DropdownMenuItem(value: 6, child: Text('RTL')),
                DropdownMenuItem(value: 9, child: Text('Land')),
              ],
              onChanged: busy ? null : (v) {
                if (v != null) {
                  onMode(v);
                }
              },
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: busy ? null : onRtl, child: const Text('RTL')),
            const SizedBox(width: 8),
            FilledButton(onPressed: busy ? null : onLand, child: const Text('Land')),
          ],
        ),
      ),
    );
  }
}

class _MissionSidePanel extends StatelessWidget {
  const _MissionSidePanel({
    required this.mission,
    required this.defaultAlt,
    required this.placingFence,
    required this.busy,
    required this.onAltChanged,
    required this.onDownload,
    required this.onUpload,
    required this.onClear,
    required this.onImport,
    required this.onExport,
    required this.onSetA,
    required this.onSetB,
    required this.onGenerateAb,
    required this.onToggleFence,
    required this.onRemove,
    required this.onEditAlt,
  });

  final List<MissionItem> mission;
  final double defaultAlt;
  final bool placingFence;
  final bool busy;
  final ValueChanged<double> onAltChanged;
  final VoidCallback onDownload;
  final VoidCallback onUpload;
  final VoidCallback onClear;
  final VoidCallback onImport;
  final VoidCallback onExport;
  final VoidCallback onSetA;
  final VoidCallback onSetB;
  final VoidCallback onGenerateAb;
  final VoidCallback onToggleFence;
  final void Function(int index) onRemove;
  final void Function(int index, double alt) onEditAlt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Mission', style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilledButton(onPressed: busy ? null : onDownload, child: const Text('Download')),
              FilledButton(onPressed: busy ? null : onUpload, child: const Text('Upload')),
              OutlinedButton(onPressed: busy ? null : onClear, child: const Text('Clear')),
              OutlinedButton(onPressed: onImport, child: const Text('Import')),
              OutlinedButton(onPressed: onExport, child: const Text('Export')),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Text('Default alt'),
              Expanded(
                child: Slider(value: defaultAlt, min: 5, max: 80, onChanged: onAltChanged),
              ),
              Text('${defaultAlt.round()} m'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton(onPressed: onSetA, child: const Text('Set A')),
              OutlinedButton(onPressed: onSetB, child: const Text('Set B')),
              FilledButton.tonal(onPressed: onGenerateAb, child: const Text('AB spray')),
              OutlinedButton(
                onPressed: onToggleFence,
                child: Text(placingFence ? 'Tap map for fence…' : 'Enable circle fence'),
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('${mission.length} items — tap map to add waypoints'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: mission.length,
            itemBuilder: (context, index) {
              final item = mission[index];
              return ListTile(
                dense: true,
                title: Text('${item.seq}  ${item.commandLabel}'),
                subtitle: Text(
                  item.lat == 0 && item.lon == 0
                      ? 'alt ${item.alt.toStringAsFixed(1)} m'
                      : '${item.lat.toStringAsFixed(6)}, ${item.lon.toStringAsFixed(6)} · ${item.alt.toStringAsFixed(1)} m',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.height),
                      tooltip: 'Edit altitude',
                      onPressed: () async {
                        final controller = TextEditingController(text: item.alt.toStringAsFixed(1));
                        final next = await showDialog<double>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Altitude (m)'),
                            content: TextField(controller: controller, keyboardType: TextInputType.number),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, double.tryParse(controller.text)),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        if (next != null) {
                          onEditAlt(index, next);
                        }
                      },
                    ),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => onRemove(index)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
