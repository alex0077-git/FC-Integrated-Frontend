import 'dart:async';

import 'package:fuselage_kpp/data/mavlink/mavlink_messages.dart';
import 'package:fuselage_kpp/data/session/mavlink_connection.dart';

class CommandException implements Exception {
  const CommandException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Sends COMMAND_LONG and waits for a matching COMMAND_ACK.
class CommandService {
  CommandService(this._connection) {
    _subscription = _connection.messagesOf<CommandAck>().listen((ack) {
      if (!_acks.isClosed) {
        _acks.add(ack);
      }
    });
    _statusSubscription = _connection.messagesOf<StatusText>().listen((text) {
      if (!_statusTexts.isClosed) {
        _statusTexts.add(text);
      }
    });
  }

  static const Duration _ackTimeout = Duration(seconds: 3);
  static const int _maxAttempts = 3;

  final MavlinkConnection _connection;
  late final StreamSubscription<CommandAck> _subscription;
  late final StreamSubscription<StatusText> _statusSubscription;
  final StreamController<CommandAck> _acks = StreamController.broadcast();
  final StreamController<StatusText> _statusTexts = StreamController.broadcast();

  Stream<StatusText> get statusTexts => _statusTexts.stream;

  Future<CommandAck> sendCommand({
    required int command,
    double param1 = 0,
    double param2 = 0,
    double param3 = 0,
    double param4 = 0,
    double param5 = 0,
    double param6 = 0,
    double param7 = 0,
    bool acceptInProgress = false,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final pending = _acks.stream
          .firstWhere(
            (ack) =>
                ack.command == command &&
                (ack.result != MavResult.inProgress || acceptInProgress),
          )
          .timeout(_ackTimeout);
      _connection.send(
        CommandLong(
          command: command,
          targetSystem: _connection.targetSystem,
          targetComponent: _connection.targetComponent,
          param1: param1,
          param2: param2,
          param3: param3,
          param4: param4,
          param5: param5,
          param6: param6,
          param7: param7,
          confirmation: attempt,
        ),
      );
      try {
        final ack = await pending;
        if (ack.result == MavResult.accepted || (acceptInProgress && ack.result == MavResult.inProgress)) {
          return ack;
        }
        throw CommandException(_describeResult(command, ack.result));
      } on TimeoutException {
        lastError = CommandException('Command $command timed out waiting for acknowledgement.');
      } on CommandException catch (error) {
        lastError = error;
        break;
      }
    }
    throw lastError ?? CommandException('Command $command failed.');
  }

  Future<CommandAck> motorTest({required int motorIndex, required double throttlePercent, required double seconds}) {
    return sendCommand(
      command: MavCmd.doMotorTest,
      param1: motorIndex.toDouble(),
      param2: 0, // throttle type: percent
      param3: throttlePercent,
      param4: seconds,
      param5: 0, // motor count
      param6: 0, // test order
    );
  }

  Future<CommandAck> calibrateImu() {
    return sendCommand(
      command: MavCmd.preflightCalibration,
      param1: 0,
      param2: 0,
      param3: 0,
      param4: 0,
      param5: 1, // accel / level
      acceptInProgress: true,
    );
  }

  Future<CommandAck> calibrateCompass() {
    return sendCommand(
      command: MavCmd.preflightCalibration,
      param1: 0,
      param2: 1, // mag
      acceptInProgress: true,
    );
  }

  Future<CommandAck> setMode(int customMode) {
    return sendCommand(
      command: MavCmd.doSetMode,
      param1: 1, // custom mode
      param2: customMode.toDouble(),
    );
  }

  Future<CommandAck> returnToLaunch() => sendCommand(command: MavCmd.navReturnToLaunch);

  Future<CommandAck> land() => sendCommand(command: MavCmd.navLand);

  Future<CommandAck> arm({bool force = false}) {
    return sendCommand(
      command: MavCmd.componentArmDisarm,
      param1: 1,
      param2: force ? 21196 : 0,
    );
  }

  Future<CommandAck> disarm({bool force = false}) {
    return sendCommand(
      command: MavCmd.componentArmDisarm,
      param1: 0,
      param2: force ? 21196 : 0,
    );
  }

  Future<CommandAck> takeoff({required double altitudeMeters}) {
    return sendCommand(command: MavCmd.navTakeoff, param7: altitudeMeters);
  }

  Future<CommandAck> startMission() {
    return sendCommand(command: MavCmd.missionStart, param1: 0, param2: 0);
  }

  Future<void> dispose() async {
    unawaited(_subscription.cancel());
    unawaited(_statusSubscription.cancel());
    if (!_acks.isClosed) {
      unawaited(_acks.close());
    }
    if (!_statusTexts.isClosed) {
      unawaited(_statusTexts.close());
    }
  }

  static String _describeResult(int command, int result) {
    final label = switch (result) {
      MavResult.temporarilyRejected => 'temporarily rejected',
      MavResult.denied => 'denied',
      MavResult.unsupported => 'unsupported',
      MavResult.failed => 'failed',
      MavResult.inProgress => 'in progress',
      _ => 'result $result',
    };
    return 'Command $command was $label.';
  }
}
