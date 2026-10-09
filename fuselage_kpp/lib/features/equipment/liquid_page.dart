import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';

/// Liquid level sensor and out-of-liquid protection (液位计 / 断药保护).
class LiquidPage extends StatelessWidget {
  const LiquidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequiresConnection(
      child: PageScaffold(
        title: 'Liquid level',
        description:
            'Switch-type level sensor connects to FC port K2. A flow meter connects to port K1 '
            'and enables precise spraying as soon as it is plugged in.',
        children: [ParamFormCard(title: 'Level sensor & protection', section: ParamSection.liquid)],
      ),
    );
  }
}
