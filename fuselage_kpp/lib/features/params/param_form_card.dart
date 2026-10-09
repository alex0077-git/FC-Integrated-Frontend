import 'package:flutter/material.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/data/params/param_catalog.dart';
import 'package:fuselage_kpp/data/params/param_spec.dart';
import 'package:fuselage_kpp/features/params/param_field.dart';

/// A card listing every parameter of one [ParamSection].
class ParamFormCard extends StatelessWidget {
  const ParamFormCard({super.key, required this.title, required this.section, this.subtitle, this.excludeIds = const {}});

  final String title;
  final String? subtitle;
  final ParamSection section;
  final Set<String> excludeIds;

  @override
  Widget build(BuildContext context) {
    final specs = [
      for (final spec in ParamCatalog.inSection(section))
        if (!excludeIds.contains(spec.id)) spec,
    ];
    return AppCard(
      title: title,
      subtitle: subtitle ?? 'Type a value and press Enter to write it to the flight controller.',
      child: Column(
        children: [
          for (var i = 0; i < specs.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ParamField(key: ValueKey(specs[i].id), spec: specs[i]),
          ],
        ],
      ),
    );
  }
}
