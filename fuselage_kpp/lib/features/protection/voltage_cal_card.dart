import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

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
    final l10n = KppLocalizations.of(context);
    final measured = double.tryParse(_controller.text.trim());
    final reported = ref.read(telemetryProvider).voltage;
    final messenger = ScaffoldMessenger.of(context);
    if (measured == null || measured <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.enterValidMeterVoltage)));
      return;
    }
    if (reported == null || reported <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.noBatteryVoltageYet)));
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
    final l10n = KppLocalizations.of(context);
    final voltage = ref.watch(telemetryProvider.select((t) => t.voltage));
    final mult = ref.watch(paramValuesProvider.select((v) => v['BATT_VOLT_MULT']));
    final reading = voltage == null ? '—' : '${voltage.toStringAsFixed(2)} V';
    final multLabel = mult?.toStringAsFixed(4) ?? '—';
    return AppCard(
      title: l10n.voltageCalibration,
      subtitle: l10n.voltageCalibrationSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.fcReadingAndMultiplier(reading, multLabel)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.meterVoltageV,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(onPressed: _calibrate, child: Text(l10n.calibrateVoltage)),
          ),
        ],
      ),
    );
  }
}
