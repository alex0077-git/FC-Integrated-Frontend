import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Gains (感度): basic, control and speed / sensitivity gains.
class GainsPage extends StatelessWidget {
  const GainsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destGains,
        description: l10n.gainsDescription,
        children: [
          ParamFormCard(title: l10n.cardBasicGains, section: ParamSection.basicGains),
          ParamFormCard(title: l10n.cardControlGains, section: ParamSection.controlGains),
          ParamFormCard(title: l10n.cardSpeedSensitivity, section: ParamSection.speedGains),
        ],
      ),
    );
  }
}
