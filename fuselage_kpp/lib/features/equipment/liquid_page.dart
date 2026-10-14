import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Liquid level sensor and out-of-liquid protection.
class LiquidPage extends StatelessWidget {
  const LiquidPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destLiquid,
        children: [ParamFormCard(title: l10n.cardLevelSensorProtection, section: ParamSection.liquid)],
      ),
    );
  }
}
