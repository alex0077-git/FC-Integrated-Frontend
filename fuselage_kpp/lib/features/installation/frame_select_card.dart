import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/params/param_catalog.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/features/installation/frame_layout_diagram.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';
import 'package:fuselage_kpp/l10n/param_l10n.dart';

/// Frame type picker writing FRAME + SHAPE, with motor-layout diagrams.
class FrameSelectCard extends ConsumerWidget {
  const FrameSelectCard({super.key});

  static const _frames = <(int, String)>[
    (1, 'Quad X'),
    (2, 'Quad +'),
    (3, 'Hexa X'),
    (4, 'Hexa +'),
    (5, 'Octo X'),
    (6, 'Octo +'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KppLocalizations.of(context);
    final values = ref.watch(paramValuesProvider);
    final current = values['FRAME']?.round() ?? 1;
    final shape = values['SHAPE']?.round() ?? 1;
    final shapeOptions = ParamCatalog.byId('SHAPE')!.options!;

    return AppCard(
      title: l10n.cardFrameType,
      subtitle: l10n.frameTypeSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (id, label) in _frames)
                _FrameChoiceTile(
                  label: ParamL10n.option(l10n, label),
                  selected: current == id,
                  diagram: FrameLayoutDiagram(frameId: id, selected: current == id),
                  onTap: () => writeParamsFromUi(
                    context,
                    ref,
                    values: {'FRAME': id.toDouble()},
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.shape, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final entry in shapeOptions.entries)
                _FrameChoiceTile(
                  label: ParamL10n.option(l10n, entry.value),
                  selected: shape == entry.key,
                  diagram: FrameShapeDiagram(
                    shapeId: entry.key,
                    selected: shape == entry.key,
                  ),
                  onTap: () => writeParamsFromUi(
                    context,
                    ref,
                    values: {'SHAPE': entry.key.toDouble()},
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FrameChoiceTile extends StatelessWidget {
  const _FrameChoiceTile({
    required this.label,
    required this.selected,
    required this.diagram,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Widget diagram;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.55) : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              diagram,
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? scheme.primary : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
