import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/params/param_catalog.dart';
import 'package:fuselage_kpp/data/repositories/parameter_repository.dart';
import 'package:fuselage_kpp/features/params/param_write.dart';

/// Frame type picker writing FRAME + SHAPE.
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
    final values = ref.watch(paramValuesProvider);
    final current = values['FRAME']?.round() ?? 1;
    final shape = values['SHAPE']?.round() ?? 1;
    final shapeOptions = ParamCatalog.byId('SHAPE')!.options!;

    return AppCard(
      title: 'Frame type',
      subtitle: 'Select the motor layout. Changes write FRAME and SHAPE to the flight controller.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (id, label) in _frames)
                ChoiceChip(
                  label: Text(label),
                  selected: current == id,
                  onSelected: (_) => writeParamsFromUi(context, ref, values: {'FRAME': id.toDouble()}),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Shape', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in shapeOptions.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: shape == entry.key,
                  onSelected: (_) => writeParamsFromUi(context, ref, values: {'SHAPE': entry.key.toDouble()}),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
