import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/pending_feature_card.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';

/// Firmware, versions, authorisation and maintenance (固件升级 / 配置).
class FirmwarePage extends ConsumerWidget {
  const FirmwarePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(paramValuesProvider.select((p) => p['FWVERSION']));
    return RequiresConnection(
      child: PageScaffold(
        title: 'Firmware & about',
        children: [
          AppCard(
            title: 'Versions',
            child: Text(
              'Flight controller firmware: ${version?.toStringAsFixed(0) ?? '—'}\n'
              'Fuselage-K++ 1.0.0 — built to replace the JIYI K++ assistant (JIYI221014).',
            ),
          ),
          const ParamFormCard(title: 'Versions & authorisation', section: ParamSection.system),
          const PendingFeatureCard(
            title: 'Firmware upgrade',
            description:
                'Upload K++ V2 / KX / P3 firmware through the flight controller bootloader. '
                'Never remove the device while upgrading.',
            actionLabel: 'Upgrade firmware',
          ),
          const PendingFeatureCard(
            title: 'Factory reset',
            description: 'Restore every parameter to the factory defaults.',
            actionLabel: 'Restore factory settings',
          ),
          const PendingFeatureCard(
            title: 'Drone registration',
            description: 'Manufacturer name, aircraft model and aircraft number (网络备案).',
          ),
        ],
      ),
    );
  }
}
