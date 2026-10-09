import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';
import 'package:fuselage_kpp/features/remote_control/stick_calibration.dart';

enum _Step { idle, extremes, centre, review }

/// Stick calibration wizard (摇杆校准) writing RC1-4 MIN / MAX / TRIM.
///
/// Stateful because it walks through several steps while recording live
/// RC values.
class RcCalibrationCard extends ConsumerStatefulWidget {
  const RcCalibrationCard({super.key});

  @override
  ConsumerState<RcCalibrationCard> createState() => _RcCalibrationCardState();
}

class _RcCalibrationCardState extends ConsumerState<RcCalibrationCard> {
  _Step _step = _Step.idle;
  StickCalibration _calibration = StickCalibration();

  void _start() => setState(() {
    _calibration = StickCalibration();
    _step = _Step.extremes;
  });

  void _captureCentre() {
    _calibration.recordCentre(ref.read(telemetryProvider).rcChannels);
    setState(() => _step = _Step.review);
  }

  Future<void> _save() async {
    final values = {for (final result in _calibration.results()) ...result.toParams()};
    final failed = await writeParamsFromUi(context, ref, values: values);
    if (mounted && failed.isEmpty) {
      setState(() => _step = _Step.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _Step.extremes) {
      ref.listen(telemetryProvider.select((t) => t.rcChannels), (_, channels) => _calibration.recordExtremes(channels));
    }
    final params = ref.watch(paramValuesProvider);

    return AppCard(
      title: 'Stick calibration',
      subtitle: switch (_step) {
        _Step.idle => 'Current endpoints are shown below. Start to recalibrate channels 1–4.',
        _Step.extremes => 'Push every stick to its maximum and minimum several times, then press Next.',
        _Step.centre => 'Release every stick to the centre, then press Capture centre.',
        _Step.review => 'Check the results, then save them to the flight controller.',
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResultsTable(rows: _step == _Step.review ? _calibration.results() : _fromParams(params)),
          const SizedBox(height: 12),
          if (_step == _Step.review && _calibration.invalidChannels().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Channel min/max out of range: CH${_calibration.invalidChannels().join(', CH')}. Calibration failed — try again.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Wrap(
            spacing: 12,
            children: [
              switch (_step) {
                _Step.idle => FilledButton(onPressed: _start, child: const Text('Start calibration')),
                _Step.extremes => FilledButton(
                  onPressed: () => setState(() => _step = _Step.centre),
                  child: const Text('Next'),
                ),
                _Step.centre => FilledButton(onPressed: _captureCentre, child: const Text('Capture centre')),
                _Step.review => FilledButton(
                  onPressed: _calibration.invalidChannels().isEmpty ? _save : null,
                  child: const Text('Save calibration'),
                ),
              },
              if (_step != _Step.idle)
                TextButton(onPressed: () => setState(() => _step = _Step.idle), child: const Text('Cancel')),
            ],
          ),
        ],
      ),
    );
  }

  static List<ChannelCalibration> _fromParams(Map<String, double> params) {
    int read(String id) => params[id]?.round() ?? 0;
    return [
      for (var ch = 1; ch <= StickCalibration.stickChannels; ch++)
        ChannelCalibration(channel: ch, min: read('RC${ch}_MIN'), max: read('RC${ch}_MAX'), trim: read('RC${ch}_TRIM')),
    ];
  }
}

class _ResultsTable extends StatelessWidget {
  const _ResultsTable({required this.rows});

  final List<ChannelCalibration> rows;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowHeight: 36,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 36,
      columns: const [
        DataColumn(label: Text('Channel')),
        DataColumn(label: Text('Min'), numeric: true),
        DataColumn(label: Text('Centre'), numeric: true),
        DataColumn(label: Text('Max'), numeric: true),
      ],
      rows: [
        for (final row in rows)
          DataRow(
            cells: [
              DataCell(Text('CH${row.channel}')),
              DataCell(Text('${row.min}')),
              DataCell(Text('${row.trim}')),
              DataCell(Text('${row.max}')),
            ],
          ),
      ],
    );
  }
}
