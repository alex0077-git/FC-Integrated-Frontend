import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/pending_feature_card.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Firmware, versions, authorisation and maintenance (固件升级 / 配置).
class FirmwarePage extends ConsumerWidget {
  const FirmwarePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KppLocalizations.of(context);
    final version = ref.watch(paramValuesProvider.select((p) => p['FWVERSION']));
    final versionLabel = version?.toStringAsFixed(0) ?? '—';
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destFirmware,
        children: [
          AppCard(
            title: l10n.cardVersions,
            child: Text('${l10n.fcFirmwareInfo(versionLabel)}\n${l10n.appAboutLine}'),
          ),
          ParamFormCard(title: l10n.cardVersionsAuthorisation, section: ParamSection.system),
          PendingFeatureCard(
            title: l10n.firmwareUpgrade,
            description: l10n.firmwareUpgradeDescription,
            actionLabel: l10n.upgradeFirmware,
          ),
          PendingFeatureCard(
            title: l10n.factoryReset,
            description: l10n.factoryResetDescription,
            actionLabel: l10n.restoreFactorySettings,
          ),
          PendingFeatureCard(
            title: l10n.droneRegistration,
            description: l10n.droneRegistrationDescription,
          ),
        ],
      ),
    );
  }
}
