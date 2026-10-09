import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';

/// Pump settings (水泵设置).
class PumpPage extends StatelessWidget {
  const PumpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequiresConnection(
      child: PageScaffold(
        title: 'Pump',
        description:
            'Single pump: pump ESC on port P1. Double pump: ESCs on P1 and P2 — '
            'P1 runs while flying forward, P2 while flying backward.',
        children: [ParamFormCard(title: 'Pump', section: ParamSection.pump)],
      ),
    );
  }
}
