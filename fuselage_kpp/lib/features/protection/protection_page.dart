import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/features/protection/voltage_cal_card.dart';

/// Protection (保护功能): low-voltage levels, PMU fault, return-home and landing.
class ProtectionPage extends ConsumerWidget {
  const ProtectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voltage = ref.watch(telemetryProvider.select((t) => t.voltage));
    return RequiresConnection(
      child: PageScaffold(
        title: 'Protection',
        description:
            'Current voltage: ${voltage == null ? '—' : '${voltage.toStringAsFixed(2)} V'}. '
            'Level 2 must be lower than level 1; both levels also flash the lights.',
        children: const [
          ParamFormCard(
            title: 'Voltage, return home & landing',
            section: ParamSection.protection,
            excludeIds: {'BATT_VOLT_MULT'},
          ),
          VoltageCalCard(),
        ],
      ),
    );
  }
}
