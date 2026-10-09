import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/flight/motor_test_card.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';

/// Motors and global flight parameters (动力配置 / 全局参数).
class FlightPage extends StatelessWidget {
  const FlightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequiresConnection(
      child: PageScaffold(
        title: 'Motors & flight',
        children: [
          ParamFormCard(title: 'Global flight limits & motor idle', section: ParamSection.flight),
          MotorTestCard(),
        ],
      ),
    );
  }
}
