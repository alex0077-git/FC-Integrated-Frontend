import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/flight/motor_test_card.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Motors and global flight parameters (动力配置 / 全局参数).
class FlightPage extends StatelessWidget {
  const FlightPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destFlight,
        children: [
          ParamFormCard(title: l10n.cardGlobalFlightLimits, section: ParamSection.flight),
          const MotorTestCard(),
        ],
      ),
    );
  }
}
