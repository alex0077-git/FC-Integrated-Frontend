import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Geofence (围栏功能): height and distance limits and the breach action.
class FencePage extends ConsumerWidget {
  const FencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KppLocalizations.of(context);
    final enabled = (ref.watch(paramValuesProvider.select((p) => p['FENCE_ENABLE'] ?? 0))) > 0;
    final radius = ref.watch(paramValuesProvider.select((p) => p['FENCE_RADIUS'] ?? 500));
    final alt = ref.watch(paramValuesProvider.select((p) => p['FENCE_ALT_MAX'] ?? 30));

    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destFence,
        description: l10n.fenceDescription,
        children: [
          AppCard(
            title: l10n.cardQuickFence,
            subtitle: enabled ? l10n.fenceEnabled : l10n.fenceOff,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => writeParamsFromUi(
                    context,
                    ref,
                    values: {
                      'FENCE_ENABLE': 1,
                      'FENCE_TYPE': 3,
                      'FENCE_RADIUS': radius,
                      'FENCE_ALT_MAX': alt,
                    },
                  ),
                  child: Text(l10n.enableAltitudeAndCircle),
                ),
                OutlinedButton(
                  onPressed: () => writeParamsFromUi(
                    context,
                    ref,
                    values: {'FENCE_ENABLE': 0, 'FENCE_TYPE': 0},
                  ),
                  child: Text(l10n.disableFence),
                ),
              ],
            ),
          ),
          ParamFormCard(title: l10n.cardHeightDistanceLimits, section: ParamSection.fence),
        ],
      ),
    );
  }
}
