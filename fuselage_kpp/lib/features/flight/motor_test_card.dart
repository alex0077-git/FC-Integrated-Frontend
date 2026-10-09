import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove propellers'),
        content: Text(
          'Motor test will spin M$_motor at ${_throttle.round()}% for ${_seconds.toStringAsFixed(1)} s.\n'
          'Confirm propellers are removed and the aircraft is secured.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Start test')),
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
      messenger.showSnackBar(SnackBar(content: Text('Motor M$_motor test accepted')));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Motor test failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Motor test',
      subtitle: 'Spins each motor individually to check order and direction.',
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
          Text('Throttle ${_throttle.round()} %'),
          Slider(
            value: _throttle,
            min: 5,
            max: 30,
            divisions: 25,
            onChanged: _busy ? null : (v) => setState(() => _throttle = v),
          ),
          Text('Duration ${_seconds.toStringAsFixed(1)} s'),
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
              child: Text(_busy ? 'Testing…' : 'Test motors'),
            ),
          ),
        ],
      ),
    );
  }
}
