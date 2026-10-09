import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/pending_feature_card.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';

/// Extension modules (扩展模块): RTK, terrain radar, obstacle radar, vision.
class ExtensionsPage extends ConsumerWidget {
  const ExtensionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fix = ref.watch(telemetryProvider.select((t) => t.gpsFixLabel));
    return RequiresConnection(
      child: PageScaffold(
        title: 'Extensions',
        children: [
          ParamFormCard(title: 'RTK antenna', subtitle: 'Current positioning: $fix', section: ParamSection.extensions),
          const PendingFeatureCard(
            title: 'Radar, vision & 4G module status',
            description:
                'Terrain-following radar height, obstacle radar distance, vision module state and the '
                'IoT SIM status are shown here in the K++ assistant.',
          ),
        ],
      ),
    );
  }
}
