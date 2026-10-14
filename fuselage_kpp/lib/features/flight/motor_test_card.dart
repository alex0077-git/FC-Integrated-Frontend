import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Motor test (M1–M8) via MAV_CMD_DO_MOTOR_TEST.
class MotorTestCard extends ConsumerStatefulWidget {
  const MotorTestCard({super.key});

  @override
  ConsumerState<MotorTestCard> createState() => _MotorTestCardState();
}

class _MotorTestCardState extends ConsumerState<MotorTestCard> {
  int _motor = 1;
  double _throttle = 10;
  double _seconds = 2;
  bool _busy = false;

  Future<void> _run() async {
    final session = ref.read(fcSessionProvider);
    if (session == null) {
      return;
    }
    final l10n = KppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removePropellers),
        content: Text(
          l10n.motorTestConfirmMessage(
            _motor,
            '${_throttle.round()}',
            _seconds.toStringAsFixed(1),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.startTest)),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await session.commands.motorTest(motorIndex: _motor, throttlePercent: _throttle, seconds: _seconds);
      messenger.showSnackBar(SnackBar(content: Text(l10n.motorTestAccepted(_motor))));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.motorTestFailed(error.toString()))));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    return AppCard(
      title: l10n.motorTest,
      subtitle: l10n.motorTestSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (var i = 1; i <= 8; i++)
                ChoiceChip(
                  label: Text('M$i'),
                  selected: _motor == i,
                  onSelected: _busy ? null : (_) => setState(() => _motor = i),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.motorThrottlePercent('${_throttle.round()}')),
          Slider(
            value: _throttle,
            min: 5,
            max: 30,
            divisions: 25,
            onChanged: _busy ? null : (v) => setState(() => _throttle = v),
          ),
          Text(l10n.motorDurationSeconds(_seconds.toStringAsFixed(1))),
          Slider(
            value: _seconds,
            min: 1,
            max: 5,
            divisions: 8,
            onChanged: _busy ? null : (v) => setState(() => _seconds = v),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: _busy ? null : _run,
              child: Text(_busy ? l10n.testingMotors : l10n.testMotors),
            ),
          ),
        ],
      ),
    );
  }
}
