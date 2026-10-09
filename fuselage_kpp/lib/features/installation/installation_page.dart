import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/installation/frame_select_card.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';

/// Frame and installation (机架 / 安装): IMU and GPS direction and position.
class InstallationPage extends StatelessWidget {
  const InstallationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequiresConnection(
      child: PageScaffold(
        title: 'Installation',
        description:
            'Choose directions to match how the modules are mounted, and enter their offsets '
            'from the airframe\'s centre of gravity in centimetres (blue zone negative, yellow zone positive).',
        children: [
          FrameSelectCard(),
          ParamFormCard(
            title: 'IMU & GPS mounting',
            section: ParamSection.installation,
            excludeIds: {'FRAME', 'SHAPE'},
          ),
        ],
      ),
    );
  }
}
