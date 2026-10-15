import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fuselage_kpp/data/link/fc_link.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_codec.dart';
import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/params/param_catalog.dart';

/// An in-process K++ flight-controller simulator that speaks the same USB
/// serial frames as the controller, so the whole app can be exercised
/// without hardware.
class SimulatedFcLink implements FcLink {
  SimulatedFcLink({this.paramBatchInterval = const Duration(milliseconds: 5)});

  // No GPS bits / frames — simulator must not invent a Normal GPS row.
  static const int sensorFlags = _gyro | _accel | _mag | _baro;
  static const int _gyro = 1;
  static const int _accel = 2;
  static const int _mag = 4;
  static const int _baro = 8;
  static const List<int> _logSizes = [12600, 48000, 3150];
  static const Duration _heartbeatInterval = Duration(seconds: 1);

  final Duration paramBatchInterval;

  final StreamController<Uint8List> _incoming = StreamController.broadcast();
  final MavFrameEncoder _encoder = MavFrameEncoder(systemId: 1, componentId: 1);
  final MavFrameParser _parser = MavFrameParser();
  final Map<String, double> _params = {for (final spec in ParamCatalog.all) spec.id: spec.simulatedDefault};
  late final List<String> _paramOrder = _params.keys.toList();
  final List<Timer> _timers = [];
  final math.Random _random = math.Random();
  Timer? _telemetryTimer;
  int _tick = 0;
  int _customMode = 0;
  int _baseMode = 81;
  final Map<int, MissionItemInt> _mission = {};

  @override
  String get label => 'Simulator';

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  /// Current simulated parameter values, for tests.
  Map<String, double> get params => Map.unmodifiable(_params);

  @override
  Future<void> open() async {
    _timers.add(
      Timer.periodic(
        _heartbeatInterval,
        (_) => _send(Heartbeat(type: 2, autopilot: 3, customMode: _customMode, baseMode: _baseMode, systemStatus: 3)),
      ),
    );
  }

  @override
  void write(Uint8List bytes) {
    for (final packet in _parser.addBytes(bytes)) {
      _handle(packet.message);
    }
  }

  @override
  Future<void> close() async {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
    if (!_incoming.isClosed) {
      unawaited(_incoming.close());
    }
  }

  void _handle(MavMessage message) {
    switch (message) {
      case ParamRequestList():
        _streamAllParams();
      case ParamRequestRead(:final paramId, :final paramIndex):
        final id = paramIndex >= 0 && paramIndex < _paramOrder.length ? _paramOrder[paramIndex] : paramId;
        if (_params.containsKey(id)) {
          _sendParam(id);
        }
      case ParamSet(:final paramId, :final value):
        if (!_params.containsKey(paramId)) {
          return;
        }
        if (ParamCatalog.byId(paramId)?.readOnly != true) {
          _params[paramId] = value;
        }
        _sendParam(paramId);
      case RequestDataStream(:final rateHz, :final start):
        _telemetryTimer?.cancel();
        _timers.remove(_telemetryTimer);
        _telemetryTimer = null;
        if (start && rateHz > 0) {
          _telemetryTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ rateHz), (_) => _sendTelemetry());
          _timers.add(_telemetryTimer!);
        }
      case KppLinkSetup() || KppAppReady():
        break;
      case LogRequestList():
        _sendLogList();
      case LogRequestData(:final logId, :final offset, :final count):
        _sendLogData(logId, offset, count);
      case CommandLong(:final command, :final param1, :final param2):
        _handleCommand(command, param1, param2);
      case SetMode(:final baseMode, :final customMode):
        _customMode = customMode;
        _baseMode = baseMode;
        _send(Heartbeat(type: 2, autopilot: 3, customMode: _customMode, baseMode: _baseMode, systemStatus: 3));
      case MissionRequestList():
        _send(MissionCount(count: _mission.length, targetSystem: 255, targetComponent: 190));
      case MissionRequestInt(:final seq):
        final item = _mission[seq];
        if (item != null) {
          _send(item);
        }
      case MissionCount(:final count):
        _mission.clear();
        _expectingMissionCount = count;
        if (count == 0) {
          _send(const MissionAck(targetSystem: 255, targetComponent: 190, type: MavMissionResult.accepted));
        } else {
          _send(const MissionRequestInt(seq: 0, targetSystem: 255, targetComponent: 190));
        }
      case MissionItemInt():
        _mission[message.seq] = message;
        if (_expectingMissionCount > 0 && _mission.length >= _expectingMissionCount) {
          _send(const MissionAck(targetSystem: 255, targetComponent: 190, type: MavMissionResult.accepted));
          _expectingMissionCount = 0;
        } else {
          _send(MissionRequestInt(seq: message.seq + 1, targetSystem: 255, targetComponent: 190));
        }
      case MissionClearAll():
        _mission.clear();
        _send(const MissionAck(targetSystem: 255, targetComponent: 190, type: MavMissionResult.accepted));
      default:
        break;
    }
  }

  int _expectingMissionCount = 0;

  void _handleCommand(int command, double param1, double param2) {
    switch (command) {
      case MavCmd.doSetMode:
        _customMode = param2.round();
        _send(CommandAck(command: command, result: MavResult.accepted));
        _send(Heartbeat(type: 2, autopilot: 3, customMode: _customMode, baseMode: _baseMode, systemStatus: 3));
      case MavCmd.componentArmDisarm:
        final arm = param1 >= 0.5;
        _baseMode = arm ? (_baseMode | 128) : (_baseMode & ~128);
        _send(CommandAck(command: command, result: MavResult.accepted));
        _send(Heartbeat(type: 2, autopilot: 3, customMode: _customMode, baseMode: _baseMode, systemStatus: 3));
      case MavCmd.navTakeoff:
        _customMode = CopterMode.guided;
        _baseMode = _baseMode | 128;
        _send(CommandAck(command: command, result: MavResult.accepted));
      case MavCmd.missionStart:
        _customMode = CopterMode.auto;
        _send(CommandAck(command: command, result: MavResult.accepted));
      case MavCmd.doMotorTest:
      case MavCmd.preflightCalibration:
      case MavCmd.navReturnToLaunch:
      case MavCmd.navLand:
        if (command == MavCmd.navReturnToLaunch) {
          _customMode = CopterMode.rtl;
        } else if (command == MavCmd.navLand) {
          _customMode = CopterMode.land;
        }
        _send(CommandAck(command: command, result: MavResult.accepted));
        if (command == MavCmd.preflightCalibration) {
          _send(StatusText(severity: 6, text: param2 > 0 ? 'Compass calibration started' : 'IMU calibration done'));
        }
      default:
        _send(CommandAck(command: command, result: MavResult.unsupported));
    }
  }

  void _streamAllParams() {
    var index = 0;
    late final Timer timer;
    timer = Timer.periodic(paramBatchInterval, (_) {
      if (index >= _paramOrder.length) {
        timer.cancel();
        return;
      }
      _sendParam(_paramOrder[index]);
      index++;
    });
    _timers.add(timer);
  }

  void _sendParam(String id) {
    _send(
      ParamValue(
        paramId: id,
        value: _params[id]!,
        type: MavParamType.real32,
        count: _paramOrder.length,
        index: _paramOrder.indexOf(id),
      ),
    );
  }

  /// Random integer in [-amplitude, amplitude], for sensor noise.
  int _noise(int amplitude) => _random.nextInt(2 * amplitude + 1) - amplitude;

  void _sendTelemetry() {
    _tick++;
    final wave = math.sin(_tick / 8);
    int stick(double phase) => (1500 + 400 * math.sin(_tick / 10 + phase)).round();

    _send(
      SysStatus(
        sensorsPresent: sensorFlags,
        sensorsEnabled: sensorFlags,
        sensorsHealth: sensorFlags,
        load: 230,
        voltageMillivolts: 48200 + (wave * 150).round(),
        currentCentiamps: 120,
        batteryRemaining: 82,
      ),
    );
    for (var instance = 0; instance < 3; instance++) {
      _send(
        ImuSample(
          instance: instance,
          acc: [_noise(3), _noise(3), -1000 + _noise(3)],
          gyro: [_noise(2), _noise(2), _noise(2)],
          mag: [210 + _noise(4), -35 + _noise(4), 410 + _noise(4)],
        ),
      );
    }
    _send(ScaledPressure(pressureHpa: 1009.2 + wave * 0.05, temperatureCenti: 3150));
    _send(
      RcChannelsRaw(port: 0, channels: [stick(0), stick(1), stick(2), stick(3), 1100, 1500, 1900, 1500], rssi: 230),
    );
    _send(const RcChannelsRaw(port: 1, channels: [1500, 1500, 1100, 1100, 1500, 1500, 1500, 1500], rssi: 230));
  }

  void _sendLogList() {
    for (var i = 0; i < _logSizes.length; i++) {
      _send(
        LogEntry(
          id: i + 1,
          numLogs: _logSizes.length,
          lastLogNum: _logSizes.length,
          size: _logSizes[i],
          timeUtc: 1791331200 + i * 3600,
        ),
      );
    }
  }

  void _sendLogData(int logId, int offset, int count) {
    if (logId < 1 || logId > _logSizes.length) {
      return;
    }
    final size = _logSizes[logId - 1];
    final end = math.min(size, offset + count);
    for (var start = offset; start < end; start += LogData.chunkSize) {
      final length = math.min(LogData.chunkSize, end - start);
      _send(
        LogData(
          logId: logId,
          offset: start,
          data: Uint8List.fromList(List.generate(length, (i) => (start + i) & 0xFF)),
        ),
      );
    }
  }

  void _send(MavMessage message) {
    if (!_incoming.isClosed) {
      _incoming.add(_encoder.encode(message));
    }
  }
}
