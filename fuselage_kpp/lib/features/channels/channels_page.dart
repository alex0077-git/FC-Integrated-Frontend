import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/params/param_catalog.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/features/params/param_form_card.dart';
import 'package:fuselage_kpp/features/remote_control/channel_monitor_card.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Channel mapping (映射功能): function of RC channels 6-12, with the K++
/// duplicate-channel warning (通道重复).
class ChannelsPage extends ConsumerWidget {
  const ChannelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KppLocalizations.of(context);
    final params = ref.watch(paramValuesProvider);
    final duplicates = duplicateChannelFunctions(params);
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destChannels,
        description: l10n.channelsDescription,
        children: [
          if (duplicates.isNotEmpty)
            MaterialBanner(
              content: Text(l10n.duplicateChannelFunctions(duplicates.join('; '))),
              leading: const Icon(Icons.warning_amber),
              actions: const [SizedBox.shrink()],
            ),
          ParamFormCard(title: l10n.cardChannelFunctions, section: ParamSection.channels),
          const ChannelMonitorCard(),
        ],
      ),
    );
  }
}

/// Lists function values (other than 0 = unused) assigned to more than one
/// channel, e.g. "function 3 on CH6, CH9".
List<String> duplicateChannelFunctions(Map<String, double> params) {
  final channelsByFunction = <int, List<String>>{};
  for (final spec in ParamCatalog.inSection(ParamSection.channels)) {
    final function = params[spec.id]?.round();
    if (function != null && function != 0) {
      channelsByFunction.putIfAbsent(function, () => []).add(spec.id.replaceAll('_OPT', ''));
    }
  }
  return [
    for (final entry in channelsByFunction.entries)
      if (entry.value.length > 1) 'function ${entry.key} on ${entry.value.join(', ')}',
  ];
}
