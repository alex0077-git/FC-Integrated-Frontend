import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/map/map_gps_focus.dart';
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
import 'package:fuselage_kpp/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';

/// Mission Planner–style map GCS: HUD, waypoints, AB spray, fence circle, modes.
class MissionPage extends ConsumerStatefulWidget {
  const MissionPage({super.key});

  @override
  ConsumerState<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends ConsumerState<MissionPage> {
  final _mapController = MapController();
  final _gpsFocus = MapGpsFocus();
  double _defaultAlt = 20;
  LatLng? _pointA;
  LatLng? _pointB;
  bool _placingFence = false;
  bool _busy = false;
  String? _message;

  LatLng get _center => liveFcGpsPoint(ref) ?? const LatLng(12.9716, 77.5946);

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
    final l10n = KppLocalizations.of(context);
    setState(
      () => _message = l10n.fenceCircleEnabled('${radius.round()}'),
    );
  }

  Future<void> _generateAb() async {
    final a = _pointA;
    final b = _pointB;
    if (a == null || b == null) {
      setState(() => _message = KppLocalizations.of(context).setPointsAbFirst);
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
    setState(
      () => _message = KppLocalizations.of(context).abSprayGenerated(mission.length),
    );
  }

  Future<void> _exportWaypoints() async {
    final text = WaypointFile.encode(ref.read(missionProvider));
    final path = await getSaveLocation(suggestedName: 'mission.waypoints');
    if (path == null) {
      return;
    }
    await File(path.path).writeAsString(text);
    setState(() => _message = KppLocalizations.of(context).exportedTo(path.path));
  }

  Future<void> _importWaypoints() async {
    final file = await openFile(acceptedTypeGroups: [const XTypeGroup(label: 'waypoints', extensions: ['waypoints', 'txt'])]);
    if (file == null) {
      return;
    }
    final text = await file.readAsString();
    ref.read(missionProvider.notifier).replace(WaypointFile.decode(text));
    setState(
      () => _message = KppLocalizations.of(context).importedItems(
        ref.read(missionProvider).length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mission = ref.watch(missionProvider);
    final telemetry = ref.watch(telemetryProvider);
    final hasSession = ref.watch(fcConnectionProvider.select((s) => s.hasSession));

    // New FC session → allow the map to snap again after remount.
    ref.listen(fcConnectionProvider.select((s) => s.session), (previous, next) {
      if (next != previous) {
        _gpsFocus.reset();
      }
    });

    // Snap when FC GPS is already live or arrives later (listen alone misses a
    // pre-existing fix because Riverpod only notifies on changes).
    ref.listen(telemetryProvider, (previous, next) {
      _gpsFocus.tryFocusFc(ref, _mapController);
    });

    if (hasSession && !_gpsFocus.applied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _gpsFocus.applied) {
          return;
        }
        _gpsFocus.focusOnOpen(ref, _mapController);
      });
    }

    return RequiresConnection(
      child: Column(
        children: [
          _HudBar(
            telemetry: telemetry,
            busy: _busy,
            onRtl: () {
              final l10n = KppLocalizations.of(context);
              _run(
                () => ref.read(fcSessionProvider)!.commands.returnToLaunch(),
                l10n.rtlAccepted,
              );
            },
            onLand: () {
              final l10n = KppLocalizations.of(context);
              _run(() => ref.read(fcSessionProvider)!.commands.land(), l10n.landAccepted);
            },
            onMode: (mode) {
              final l10n = KppLocalizations.of(context);
              _run(
                () => ref.read(fcSessionProvider)!.commands.setMode(mode),
                l10n.modeSet('$mode'),
              );
            },
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
                      initialZoom: mapGpsFocusZoom,
                      onMapReady: () {
                        _gpsFocus.reset();
                        _gpsFocus.focusOnOpen(ref, _mapController);
                      },
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
                      onDownload: () {
                        final l10n = KppLocalizations.of(context);
                        _run(
                          () => ref.read(missionProvider.notifier).download(),
                          l10n.missionDownloaded,
                        );
                      },
                      onUpload: () {
                        final l10n = KppLocalizations.of(context);
                        _run(
                          () => ref.read(missionProvider.notifier).upload(),
                          l10n.missionUploaded,
                        );
                      },
                      onClear: () {
                        final l10n = KppLocalizations.of(context);
                        _run(
                          () => ref.read(missionProvider.notifier).clearRemote(),
                          l10n.missionCleared,
                        );
                      },
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

  /// Prefer the stronger of GPS1 / GPS2 (agri puck is usually GPS2 on K++).
  static String _bestGpsLabel(FcTelemetry t) {
    final g1 = t.gpsFixType ?? 0;
    final g2 = t.gps2FixType ?? 0;
    return FcTelemetry.fixLabelFor(g1 >= g2 ? t.gpsFixType : t.gps2FixType);
  }

  static String _bestGpsSats(FcTelemetry t) {
    final s1 = t.satellites ?? 0;
    final s2 = t.gps2Satellites ?? 0;
    final best = s1 >= s2 ? s1 : s2;
    return best > 0 ? '$best' : '—';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    String modeLabel() {
      final m = telemetry.customMode;
      return switch (m) {
        null => '—',
        0 => 'Stabilize',
        2 => 'AltHold',
        3 => l10n.flightModeAuto,
        4 => l10n.flightModeGuided,
        5 => l10n.flightModeLoiter,
        6 => l10n.flightModeRtl,
        9 => l10n.flightModeLand,
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
                '${telemetry.armed ? l10n.armed : l10n.disarmed}  ·  $modeLabel()  ·  '
                'GPS ${_bestGpsLabel(telemetry)} (${_bestGpsSats(telemetry)} sats)  ·  '
                '${telemetry.voltage == null ? '— V' : '${telemetry.voltage!.toStringAsFixed(1)} V'}  ·  '
                'Alt ${telemetry.altMeters == null ? '—' : '${telemetry.altMeters!.toStringAsFixed(1)} m'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Spacer(),
            DropdownButton<int>(
              hint: Text(l10n.setMode),
              items: [
                DropdownMenuItem(value: 3, child: Text(l10n.flightModeAuto)),
                DropdownMenuItem(value: 4, child: Text(l10n.flightModeGuided)),
                DropdownMenuItem(value: 5, child: Text(l10n.flightModeLoiter)),
                DropdownMenuItem(value: 6, child: Text(l10n.flightModeRtl)),
                DropdownMenuItem(value: 9, child: Text(l10n.flightModeLand)),
              ],
              onChanged: busy ? null : (v) {
                if (v != null) {
                  onMode(v);
                }
              },
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: busy ? null : onRtl, child: Text(l10n.rtl)),
            const SizedBox(width: 8),
            FilledButton(onPressed: busy ? null : onLand, child: Text(l10n.land)),
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
    final l10n = KppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l10n.destMission, style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilledButton(onPressed: busy ? null : onDownload, child: Text(l10n.download)),
              FilledButton(onPressed: busy ? null : onUpload, child: Text(l10n.upload)),
              OutlinedButton(onPressed: busy ? null : onClear, child: Text(l10n.clear)),
              OutlinedButton(onPressed: onImport, child: Text(l10n.import)),
              OutlinedButton(onPressed: onExport, child: Text(l10n.export)),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(l10n.defaultAlt),
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
              OutlinedButton(onPressed: onSetA, child: Text(l10n.setA)),
              OutlinedButton(onPressed: onSetB, child: Text(l10n.setB)),
              FilledButton.tonal(onPressed: onGenerateAb, child: Text(l10n.abSpray)),
              OutlinedButton(
                onPressed: onToggleFence,
                child: Text(placingFence ? l10n.tapMapForFence : l10n.enableCircleFence),
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(l10n.missionItemsHint(mission.length)),
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
                      tooltip: l10n.editAltitude,
                      onPressed: () async {
                        final controller = TextEditingController(text: item.alt.toStringAsFixed(1));
                        final next = await showDialog<double>(
                          context: context,
                          builder: (context) {
                            final dialogL10n = KppLocalizations.of(context);
                            return AlertDialog(
                              title: Text(dialogL10n.altitudeM),
                              content: TextField(controller: controller, keyboardType: TextInputType.number),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(dialogL10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, double.tryParse(controller.text)),
                                  child: Text(dialogL10n.ok),
                                ),
                              ],
                            );
                          },
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
