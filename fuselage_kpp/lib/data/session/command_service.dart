import 'dart:async';

import 'package:fuselage_kpp/data/link/fc_link.dart';
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

  /// JIYI REQUEST_DATA_STREAM uses component 0; arm/mode should match.
  static const int _kppBroadcastComponent = 0;

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
    int? targetComponent,
  }) async {
    final comp = targetComponent ?? _kppBroadcastComponent;
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
          targetComponent: comp,
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

  /// RTL over the live link (USB / BT / WiFi).
  ///
  /// K++ often ACKs MAV_CMD_NAV_RTL (20) as failed/unsupported. Fall back to
  /// DO_SET_MODE / SET_MODE → CopterMode.rtl — the path agri GCS apps use.
  Future<CommandAck> returnToLaunch() async {
    try {
      return await sendCommand(command: MavCmd.navReturnToLaunch);
    } on CommandException catch (error) {
      if (!_shouldFallbackToMode(error)) {
        rethrow;
      }
    }
    await _setCopterMode(CopterMode.rtl);
    return const CommandAck(command: MavCmd.navReturnToLaunch, result: MavResult.accepted);
  }

  /// Land over the live link (USB / BT / WiFi).
  /// Prefer NAV_LAND (21); if failed/unsupported, SET_MODE → Land.
  Future<CommandAck> land() async {
    try {
      return await sendCommand(command: MavCmd.navLand);
    } on CommandException catch (error) {
      if (!_shouldFallbackToMode(error)) {
        rethrow;
      }
    }
    await _setCopterMode(CopterMode.land);
    return const CommandAck(command: MavCmd.navLand, result: MavResult.accepted);
  }

  /// Arm motors. JIYI K++ usually ACKs MAV_CMD 400 as unsupported over USB —
  /// that means the link is fine; the firmware only arms from the RC. We still
  /// try SET_MODE + RC override, then tell the pilot to stick-arm.
  Future<CommandAck> arm({bool force = false}) async {
    final forceFlags = force ? const [true] : const [false, true];
    for (final useForce in forceFlags) {
      try {
        return await sendCommand(
          command: MavCmd.componentArmDisarm,
          param1: 1,
          param2: useForce ? 21196 : 0,
          targetComponent: _kppBroadcastComponent,
        );
      } on CommandException catch (error) {
        if (!_shouldFallbackToMode(error)) {
          rethrow;
        }
      }
    }

    if (await _armViaSetMode()) {
      return const CommandAck(command: MavCmd.componentArmDisarm, result: MavResult.accepted);
    }
    if (await _armViaRcStick()) {
      return const CommandAck(command: MavCmd.componentArmDisarm, result: MavResult.accepted);
    }
    throw const CommandException(
      'USB/link is OK — this K++ does not accept MAVLink Arm (cmd 400). '
      'Arm with the RC (throttle low + yaw right), then use Takeoff / mission from the app.',
    );
  }

  Future<CommandAck> disarm({bool force = false}) async {
    try {
      return await sendCommand(
        command: MavCmd.componentArmDisarm,
        param1: 0,
        param2: force ? 21196 : 0,
        targetComponent: _kppBroadcastComponent,
      );
    } on CommandException catch (error) {
      if (!_isUnsupported(error)) {
        rethrow;
      }
    }
    // Legacy disarm: clear SAFETY_ARMED via SET_MODE.
    final base = (_connection.lastBaseMode & ~SetMode.flagSafetyArmed) | SetMode.flagCustomModeEnabled;
    _connection.send(
      SetMode(
        targetSystem: _connection.targetSystem,
        baseMode: base & 0xFF,
        customMode: _connection.lastCustomMode,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!_connection.heartbeatArmed) {
      return const CommandAck(command: MavCmd.componentArmDisarm, result: MavResult.accepted);
    }
    throw const CommandException('Disarm was unsupported and SET_MODE did not clear the armed flag.');
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

  static bool _isUnsupported(CommandException error) =>
      error.message.contains('unsupported');

  /// NAV_RTL / NAV_LAND often come back failed or unsupported on K++; mode set is the real path.
  static bool _shouldFallbackToMode(CommandException error) {
    final m = error.message;
    return m.contains('unsupported') || m.contains('failed') || m.contains('denied');
  }

  /// Switch flight mode via DO_SET_MODE, then raw SET_MODE if needed, until heartbeat matches.
  Future<void> _setCopterMode(int customMode) async {
    try {
      await setMode(customMode);
      if (_connection.lastCustomMode == customMode) {
        return;
      }
    } on CommandException {
      // Fall through to SET_MODE message — K++ may reject DO_SET_MODE too.
    }

    final base = (_connection.lastBaseMode | SetMode.flagCustomModeEnabled) & 0xFF;
    _connection.send(
      SetMode(
        targetSystem: _connection.targetSystem,
        baseMode: base,
        customMode: customMode,
      ),
    );
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (DateTime.now().isBefore(deadline)) {
      if (_connection.lastCustomMode == customMode) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (_connection.lastCustomMode != customMode) {
      throw CommandException(
        'Could not switch to ${CopterMode.label(customMode)}. '
        'Confirm the aircraft is armed / has a home point, then try again.',
      );
    }
  }

  Future<bool> _armViaSetMode() async {
    final base = _connection.lastBaseMode | SetMode.flagSafetyArmed | SetMode.flagCustomModeEnabled;
    _connection.send(
      SetMode(
        targetSystem: _connection.targetSystem,
        baseMode: base & 0xFF,
        customMode: _connection.lastCustomMode,
      ),
    );
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (DateTime.now().isBefore(deadline)) {
      if (_connection.heartbeatArmed) {
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return _connection.heartbeatArmed;
  }

  /// Throttle-low + yaw-right via RC_CHANNELS_OVERRIDE (JIYI radio arm gesture).
  Future<bool> _armViaRcStick() async {
    final arm = RcChannelsOverride.stickArm(targetSystem: _connection.targetSystem);
    final release = RcChannelsOverride.release(targetSystem: _connection.targetSystem);
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (DateTime.now().isBefore(deadline)) {
      try {
        _connection.send(arm);
      } on FcLinkException {
        break;
      }
      if (_connection.heartbeatArmed) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    try {
      _connection.send(release);
    } on FcLinkException {
      // ignore
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _connection.heartbeatArmed;
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
