import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';
import 'package:fuselage_kpp/features/remote_control/stick_calibration.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

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
    final l10n = KppLocalizations.of(context);
    if (_step == _Step.extremes) {
      ref.listen(telemetryProvider.select((t) => t.rcChannels), (_, channels) => _calibration.recordExtremes(channels));
    }
    final params = ref.watch(paramValuesProvider);

    return AppCard(
      title: l10n.stickCalibration,
      subtitle: switch (_step) {
        _Step.idle => l10n.stickCalibrationIdle,
        _Step.extremes => l10n.stickCalibrationExtremes,
        _Step.centre => l10n.stickCalibrationCentre,
        _Step.review => l10n.stickCalibrationReview,
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResultsTable(l10n: l10n, rows: _step == _Step.review ? _calibration.results() : _fromParams(params)),
          const SizedBox(height: 12),
          if (_step == _Step.review && _calibration.invalidChannels().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.stickCalibrationInvalid('CH${_calibration.invalidChannels().join(', CH')}'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Wrap(
            spacing: 12,
            children: [
              switch (_step) {
                _Step.idle => FilledButton(onPressed: _start, child: Text(l10n.startCalibration)),
                _Step.extremes => FilledButton(
                  onPressed: () => setState(() => _step = _Step.centre),
                  child: Text(l10n.next),
                ),
                _Step.centre => FilledButton(onPressed: _captureCentre, child: Text(l10n.captureCentre)),
                _Step.review => FilledButton(
                  onPressed: _calibration.invalidChannels().isEmpty ? _save : null,
                  child: Text(l10n.saveCalibration),
                ),
              },
              if (_step != _Step.idle)
                TextButton(onPressed: () => setState(() => _step = _Step.idle), child: Text(l10n.cancel)),
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
  const _ResultsTable({required this.l10n, required this.rows});

  final KppLocalizations l10n;
  final List<ChannelCalibration> rows;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowHeight: 36,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 36,
      columns: [
        DataColumn(label: Text(l10n.channel)),
        DataColumn(label: Text(l10n.min), numeric: true),
        DataColumn(label: Text(l10n.centre), numeric: true),
        DataColumn(label: Text(l10n.max), numeric: true),
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
