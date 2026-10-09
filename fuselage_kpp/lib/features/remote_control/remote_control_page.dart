import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/features/remote_control/channel_monitor_card.dart';
import 'package:fuselage_kpp/features/remote_control/rc_calibration_card.dart';

/// Remote control (遥控器): RC type, failsafe, flight modes, stick
/// calibration and channel monitor.
class RemoteControlPage extends StatelessWidget {
  const RemoteControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequiresConnection(
      child: PageScaffold(
        title: 'Remote control',
        description:
            'To make sure the failsafe is set correctly, switch the RC off after changing it and check '
            'that channels 1–4 jump to centre (about 1500) and channel 5 jumps to its failsafe position.',
        children: [
          ParamFormCard(title: 'RC settings & failsafe', section: ParamSection.remoteControl),
          RcCalibrationCard(),
          ChannelMonitorCard(),
        ],
      ),
    );
  }
}
