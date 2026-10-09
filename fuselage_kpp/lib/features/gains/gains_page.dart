import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';

/// Gains (感度): basic, control and speed / sensitivity gains.
class GainsPage extends StatelessWidget {
  const GainsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequiresConnection(
      child: PageScaffold(
        title: 'Gains',
        description:
            'Control gains set the pilot\'s feel: higher values respond faster but need more power. '
            'Only move the performance tendency towards vibration suppression if the airframe visibly shakes '
            'or the motors sound noisy.',
        children: [
          ParamFormCard(title: 'Basic gains', section: ParamSection.basicGains),
          ParamFormCard(title: 'Control gains', section: ParamSection.controlGains),
          ParamFormCard(title: 'Speed & sensitivity', section: ParamSection.speedGains),
        ],
      ),
    );
  }
}
