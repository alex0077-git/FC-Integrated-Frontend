import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/features/remote_control/channel_monitor_card.dart';
import 'package:fuselage_kpp/features/remote_control/rc_calibration_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Remote control (遥控器): RC type, failsafe, flight modes, stick
/// calibration and channel monitor.
class RemoteControlPage extends StatelessWidget {
  const RemoteControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = KppLocalizations.of(context);
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destRemoteControl,
        description: l10n.remoteControlDescription,
        children: [
          ParamFormCard(title: l10n.cardRcSettingsFailsafe, section: ParamSection.remoteControl),
          const RcCalibrationCard(),
          const ChannelMonitorCard(),
        ],
      ),
    );
  }
}
