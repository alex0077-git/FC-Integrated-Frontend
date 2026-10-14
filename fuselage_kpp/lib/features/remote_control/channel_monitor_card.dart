import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Channel monitor (通道监测): live PWM bar for every RC channel.
class ChannelMonitorCard extends ConsumerWidget {
  const ChannelMonitorCard({super.key});

  static const int pwmMin = 900;
  static const int pwmMax = 2100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KppLocalizations.of(context);
    final channels = ref.watch(telemetryProvider.select((t) => t.rcChannels));
    return AppCard(
      title: l10n.channelMonitor,
      subtitle: channels.isEmpty ? l10n.channelMonitorNoData : l10n.channelMonitorHint,
      child: Column(
        children: [for (var i = 0; i < channels.length; i++) _ChannelBar(channel: i + 1, pwm: channels[i])],
      ),
    );
  }
}

class _ChannelBar extends StatelessWidget {
  const _ChannelBar({required this.channel, required this.pwm});

  final int channel;
  final int pwm;

  @override
  Widget build(BuildContext context) {
    final fraction = ((pwm - ChannelMonitorCard.pwmMin) / (ChannelMonitorCard.pwmMax - ChannelMonitorCard.pwmMin))
        .clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text('CH$channel')),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: pwm == 0 ? 0 : fraction, minHeight: 10),
            ),
          ),
          SizedBox(width: 64, child: Text(pwm == 0 ? '—' : '$pwm', textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
