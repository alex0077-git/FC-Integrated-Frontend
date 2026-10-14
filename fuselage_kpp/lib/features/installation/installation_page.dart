import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/installation/frame_select_card.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Frame and installation (机架 / 安装): IMU and GPS direction and position.
class InstallationPage extends StatelessWidget {
  const InstallationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destInstallation,
        description: l10n.installationDescription,
        children: [
          const FrameSelectCard(),
          ParamFormCard(
            title: l10n.cardImuGpsMounting,
            section: ParamSection.installation,
            excludeIds: {'FRAME', 'SHAPE'},
          ),
        ],
      ),
    );
  }
}
