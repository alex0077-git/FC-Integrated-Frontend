import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';

/// AB spraying (植保功能 / AB作业): swath, speed, U-turn and the field procedure.
class SprayingPage extends StatelessWidget {
  const SprayingPage({super.key});

  static const List<(String, String)> _procedure = [
    ('Record point A', 'Flip the AB record switch to the middle position.'),
    ('Record point B', 'Flip the AB record switch to the high position.'),
    ('Start the AB job', 'Turn on the AB execute switch (or set AB execute as a flight mode).'),
    ('Choose direction', 'Push the roll stick towards the side to work.'),
    ('Clear A and B', 'Flip the AB record switch back and forth quickly.'),
    (
      'Resume after refill',
      'Without clearing A/B, turn on AB execute: the job resumes from the last empty-tank point and direction.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RequiresConnection(
      child: PageScaffold(
        title: 'AB spraying',
        children: [
          const ParamFormCard(title: 'AB job settings', section: ParamSection.spraying),
          AppCard(
            title: 'AB job procedure',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _procedure.length; i++)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(radius: 12, child: Text('${i + 1}')),
                    title: Text(_procedure[i].$1),
                    subtitle: Text(_procedure[i].$2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
