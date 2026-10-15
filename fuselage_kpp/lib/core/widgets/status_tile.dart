import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/theme/app_theme.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';

enum StatusLevel { good, warning, critical, unknown, info }

/// Small coloured tile for one status value, like the K++ 状态检测 panel.
class StatusTile extends StatelessWidget {
  const StatusTile({super.key, required this.label, required this.value, required this.level});

  static const double width = 200;

  final String label;
  final String value;
  final StatusLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppStatusColors>() ?? AppStatusColors.dark;
    final color = switch (level) {
      StatusLevel.good => colors.statusGood,
      StatusLevel.warning => colors.statusWarning,
      StatusLevel.critical => colors.statusCritical,
      StatusLevel.unknown => Colors.grey,
      StatusLevel.info => colors.statusInfo,
    };
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCard.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
