import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';
import 'package:fuselage_kpp/features/sensors/calibration_cards.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

/// Sensors (传感器): live IMU 1-3, compass 1-3 and barometer readings,
/// plus the K++ calibration procedures.
class SensorsPage extends ConsumerWidget {
  const SensorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KppLocalizations.of(context);
    final telemetry = ref.watch(telemetryProvider);
    return RequiresConnection(
      child: PageScaffold(
        title: l10n.destSensors,
        children: [
          AppCard(
            title: l10n.cardImuCompass,
            subtitle: l10n.sensorsImuCompassSubtitle,
            child: _ImuTable(l10n: l10n, imus: telemetry.imus),
          ),
          AppCard(
            title: l10n.cardBarometer,
            child: Text(
              telemetry.pressureHpa == null
                  ? l10n.noBarometerData
                  : l10n.barometerReading(
                      telemetry.pressureHpa!.toStringAsFixed(2),
                      telemetry.temperatureC!.toStringAsFixed(1),
                    ),
            ),
          ),
          const ImuCalibrationCard(),
          const CompassCalibrationCard(),
        ],
      ),
    );
  }
}

class _ImuTable extends StatelessWidget {
  const _ImuTable({required this.l10n, required this.imus});

  final KppLocalizations l10n;
  final List<ImuReading?> imus;

  @override
  Widget build(BuildContext context) {
    String axes(List<int>? values) => values == null ? '—' : values.join(' / ');
    return DataTable(
      columns: [
        DataColumn(label: Text(l10n.instance)),
        DataColumn(label: Text(l10n.accelAxes)),
        DataColumn(label: Text(l10n.gyroAxes)),
        DataColumn(label: Text(l10n.compassAxes)),
      ],
      rows: [
        for (var i = 0; i < imus.length; i++)
          DataRow(
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(axes(imus[i]?.acc))),
              DataCell(Text(axes(imus[i]?.gyro))),
              DataCell(Text(axes(imus[i]?.mag))),
            ],
          ),
      ],
    );
  }
}
