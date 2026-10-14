import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/features/protection/voltage_cal_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Protection (保护功能): low-voltage levels, PMU fault, return-home and landing.
class ProtectionPage extends ConsumerWidget {
  const ProtectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KppLocalizations.of(context);
    final voltage = ref.watch(telemetryProvider.select((t) => t.voltage));
    final voltageLabel = voltage == null ? '—' : '${voltage.toStringAsFixed(2)} V';
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destProtection,
        description: l10n.protectionDescription(voltageLabel),
        children: [
          ParamFormCard(
            title: l10n.cardVoltageRtlLanding,
            section: ParamSection.protection,
            excludeIds: {'BATT_VOLT_MULT'},
          ),
          const VoltageCalCard(),
        ],
      ),
    );
  }
}
