import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/core/widgets/status_tile.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Liquid level sensor, flow meter (K1), and out-of-liquid protection.
class LiquidPage extends ConsumerWidget {
  const LiquidPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KppLocalizations.of(context);
    final telemetry = ref.watch(telemetryProvider);
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destLiquid,
        children: [
          AppCard(
            title: 'Live spray / liquid',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatusTile(
                  label: 'Flow meter (K1)',
                  value: telemetry.flowRateLpm == null
                      ? '—'
                      : '${telemetry.flowRateLpm!.toStringAsFixed(2)} L/min',
                  level: telemetry.flowRateLpm == null
                      ? StatusLevel.unknown
                      : StatusLevel.good,
                ),
                StatusTile(
                  label: 'Level',
                  value: telemetry.liquidLevelPercent == null
                      ? '—'
                      : '${telemetry.liquidLevelPercent!.toStringAsFixed(0)} %',
                  level: telemetry.liquidLevelPercent == null
                      ? StatusLevel.unknown
                      : StatusLevel.good,
                ),
                StatusTile(
                  label: 'Sprayed',
                  value: telemetry.sprayedLiters == null
                      ? '—'
                      : '${telemetry.sprayedLiters!.toStringAsFixed(2)} L',
                  level: telemetry.sprayedLiters == null
                      ? StatusLevel.unknown
                      : StatusLevel.good,
                ),
              ],
            ),
          ),
          ParamFormCard(title: l10n.cardLevelSensorProtection, section: ParamSection.liquid),
        ],
      ),
    );
  }
}
