import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fuselage_kpp/data/logs/dataflash_summary.dart';
import 'package:latlong2/latlong.dart';

/// Simple dataflash review: GPS track + altitude / voltage sparkline plots.
class LogReviewPage extends StatefulWidget {
  const LogReviewPage({super.key, required this.file});

  final File file;

  @override
  State<LogReviewPage> createState() => _LogReviewPageState();
}

class _LogReviewPageState extends State<LogReviewPage> {
  DataflashSummary? _summary;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bytes = await widget.file.readAsBytes();
      setState(() => _summary = DataflashSummary.parse(Uint8List.fromList(bytes)));
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return Scaffold(
      appBar: AppBar(title: Text(widget.file.uri.pathSegments.last)),
      body: _error != null
          ? Center(child: Text('Could not parse log: $_error\nOpen the .bin externally for full analysis.'))
          : summary == null
          ? const Center(child: CircularProgressIndicator())
          : summary.track.isEmpty && summary.altitudes.isEmpty
          ? const Center(child: Text('No GPS/ATT samples recognised in this log.'))
          : Column(
              children: [
                if (summary.track.isNotEmpty)
                  Expanded(
                    flex: 3,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(summary.track.first.$1, summary.track.first.$2),
                        initialZoom: 16,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.fuselage.kpp',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [for (final p in summary.track) LatLng(p.$1, p.$2)],
                              strokeWidth: 3,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _PlotCard(
                            title: 'Altitude',
                            values: [for (final s in summary.altitudes) s.$2],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PlotCard(
                            title: 'Voltage',
                            values: [for (final s in summary.voltages) s.$2],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PlotCard extends StatelessWidget {
  const _PlotCard({required this.title, required this.values});

  final String title;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Expanded(
              child: values.isEmpty
                  ? const Center(child: Text('No samples'))
                  : CustomPaint(painter: _SparklinePainter(values, Theme.of(context).colorScheme.primary)),
            ),
            if (values.isNotEmpty)
              Text(
                'min ${values.reduce(math.min).toStringAsFixed(1)}  ·  max ${values.reduce(math.max).toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs() < 1e-6 ? 1.0 : maxV - minV;
    final path = ui.Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - size.height * (values[i] - minV) / span;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.values != values;
}
