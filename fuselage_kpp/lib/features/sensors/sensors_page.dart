import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/core/widgets/app_card.dart';
import 'package:fuselage_kpp/core/widgets/page_scaffold.dart';
import 'package:fuselage_kpp/core/widgets/requires_connection.dart';
import 'package:fuselage_kpp/data/repositories/telemetry_repository.dart';
import 'package:fuselage_kpp/data/session/fc_telemetry.dart';
import 'package:fuselage_kpp/features/sensors/calibration_cards.dart';

/// Sensors (传感器): live IMU 1-3, compass 1-3 and barometer readings,
/// plus the K++ calibration procedures.
class SensorsPage extends ConsumerWidget {
  const SensorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(telemetryProvider);
    return RequiresConnection(
      child: PageScaffold(
        title: 'Sensors',
        children: [
          AppCard(
            title: 'IMU & compass',
            subtitle: 'Raw sensor values from each IMU instance.',
            child: _ImuTable(imus: telemetry.imus),
          ),
          AppCard(
            title: 'Barometer',
            child: Text(
              telemetry.pressureHpa == null
                  ? 'No barometer data'
                  : 'Pressure ${telemetry.pressureHpa!.toStringAsFixed(2)} hPa   ·   '
                        'Temperature ${telemetry.temperatureC!.toStringAsFixed(1)} °C',
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
  const _ImuTable({required this.imus});

  final List<ImuReading?> imus;

  @override
  Widget build(BuildContext context) {
    String axes(List<int>? values) => values == null ? '—' : values.join(' / ');
    return DataTable(
      columns: const [
        DataColumn(label: Text('Instance')),
        DataColumn(label: Text('Accel X / Y / Z')),
        DataColumn(label: Text('Gyro X / Y / Z')),
        DataColumn(label: Text('Compass X / Y / Z')),
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
