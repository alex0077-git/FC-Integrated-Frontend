import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';

/// Voltage calibration by adjusting BATT_VOLT_MULT from a meter reading.
class VoltageCalCard extends ConsumerStatefulWidget {
  const VoltageCalCard({super.key});

  @override
  ConsumerState<VoltageCalCard> createState() => _VoltageCalCardState();
}

class _VoltageCalCardState extends ConsumerState<VoltageCalCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _calibrate() async {
    final measured = double.tryParse(_controller.text.trim());
    final reported = ref.read(telemetryProvider).voltage;
    final messenger = ScaffoldMessenger.of(context);
    if (measured == null || measured <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Enter a valid meter voltage')));
      return;
    }
    if (reported == null || reported <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('No battery voltage from the flight controller yet')));
      return;
    }
    final currentMult = ref.read(paramValuesProvider)['BATT_VOLT_MULT'] ?? 1.0;
    final nextMult = currentMult * (measured / reported);
    await writeParamFromUi(
      context,
      ref,
      id: 'BATT_VOLT_MULT',
      value: nextMult,
      format: (v) => v.toStringAsFixed(4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voltage = ref.watch(telemetryProvider.select((t) => t.voltage));
    final mult = ref.watch(paramValuesProvider.select((v) => v['BATT_VOLT_MULT']));
    return AppCard(
      title: 'Voltage calibration',
      subtitle: 'Enter the voltage measured with a meter so the FC reading matches it.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'FC reading: ${voltage == null ? '—' : '${voltage.toStringAsFixed(2)} V'}'
            '   ·   multiplier: ${mult?.toStringAsFixed(4) ?? '—'}',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Meter voltage (V)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(onPressed: _calibrate, child: const Text('Calibrate voltage')),
          ),
        ],
      ),
    );
  }
}
