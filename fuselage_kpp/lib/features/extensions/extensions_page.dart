import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/pending_feature_card.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Extension modules (扩展模块): RTK, terrain radar, obstacle radar, vision.
class ExtensionsPage extends ConsumerWidget {
  const ExtensionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KppLocalizations.of(context);
    final fix = ref.watch(telemetryProvider.select((t) => t.gpsFixLabel));
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destExtensions,
        children: [
          ParamFormCard(
            title: l10n.cardRtkAntenna,
            subtitle: l10n.rtkCurrentPositioning(fix),
            section: ParamSection.extensions,
          ),
          PendingFeatureCard(
            title: l10n.cardRadarVision4g,
            description: l10n.extensionsRadarStatusDescription,
          ),
        ],
      ),
    );
  }
}
