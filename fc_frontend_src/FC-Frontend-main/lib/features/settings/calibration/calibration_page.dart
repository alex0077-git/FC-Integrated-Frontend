import 'package:fc_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CalibrationPage extends StatelessWidget {
  const CalibrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.calibration, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _CalibrationCard(title: l10n.calibrationRadio, rowLabels: [l10n.calibrationRadio]),
        const SizedBox(height: 12),
        _CalibrationCard(
          title: l10n.imuCalibration,
          rowLabels: ['${l10n.calibrationImu} 1', '${l10n.calibrationImu} 2'],
        ),
        const SizedBox(height: 12),
        _CalibrationCard(
          title: l10n.compassCalibration,
          rowLabels: [l10n.calibrationCompass],
        ),
      ],
    );
  }
}

class _CalibrationCard extends StatefulWidget {
  const _CalibrationCard({required this.title, required this.rowLabels});

  final String title;
  final List<String> rowLabels;

  @override
  State<_CalibrationCard> createState() => _CalibrationCardState();
}

class _CalibrationCardState extends State<_CalibrationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  var _running = false;
  var _calibrated = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progress.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) {
        return;
      }
      setState(() {
        _running = false;
        _calibrated = true;
      });
    });
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _calibrated = false;
    });
    _progress.forward(from: 0);
  }

  String _statusLabel(AppLocalizations l10n) {
    if (_running) {
      return l10n.calibrationStatusCalibrating;
    }
    if (_calibrated) {
      return l10n.calibrationStatusCalibrated;
    }
    return l10n.calibrationStatusNotCalibrated;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final label in widget.rowLabels)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(label)),
                    Text(_statusLabel(l10n)),
                  ],
                ),
              ),
            if (_running) ...[
              const SizedBox(height: 4),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, child) {
                  return LinearProgressIndicator(value: _progress.value);
                },
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _running ? null : _start,
              child: Text(l10n.startCalibrationFull),
            ),
          ],
        ),
      ),
    );
  }
}
