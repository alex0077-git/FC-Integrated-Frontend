import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// AB spraying (植保功能 / AB作业): swath, speed, U-turn and the field procedure.
class SprayingPage extends StatelessWidget {
  const SprayingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    final procedure = [
      (l10n.sprayProcedure1Title, l10n.sprayProcedure1Detail),
      (l10n.sprayProcedure2Title, l10n.sprayProcedure2Detail),
      (l10n.sprayProcedure3Title, l10n.sprayProcedure3Detail),
      (l10n.sprayProcedure4Title, l10n.sprayProcedure4Detail),
      (l10n.sprayProcedure5Title, l10n.sprayProcedure5Detail),
      (l10n.sprayProcedure6Title, l10n.sprayProcedure6Detail),
    ];
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destSpraying,
        children: [
          ParamFormCard(title: l10n.cardAbJobSettings, section: ParamSection.spraying),
          AppCard(
            title: l10n.cardAbJobProcedure,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < procedure.length; i++)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(radius: 12, child: Text('${i + 1}')),
                    title: Text(procedure[i].$1),
                    subtitle: Text(procedure[i].$2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
