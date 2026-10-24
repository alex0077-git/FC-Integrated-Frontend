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

  /// Switch flight mode. This K++ rejects command 176, so fall back to SET_MODE
  /// and wait until the heartbeat shows the new mode. Land and RTL use the same path.
  Future<CommandAck> setMode(int customMode) async {
    try {
      final ack = await sendCommand(
        command: MavCmd.doSetMode,
        param1: 1, // custom mode
        param2: customMode.toDouble(),
      );
      if (_connection.lastCustomMode == customMode) {
        return ack;
      }
    } on CommandException {
      // Command 176 unsupported/denied. Try the legacy SET_MODE message.
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
        return const CommandAck(command: MavCmd.doSetMode, result: MavResult.accepted);
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (_connection.lastCustomMode != customMode) {
      throw CommandException(
        'Could not switch to ${CopterMode.label(customMode)}. '
        'The transmitter mode switch is holding the current mode.',
      );
    }
    return const CommandAck(command: MavCmd.doSetMode, result: MavResult.accepted);
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

  /// Arm motors from the GCS. Transmitter stick-arm stays fully available too —
  /// both work in parallel. After any GCS attempt we always release RC override
  /// so the TX sticks are free again.
  ///
  /// App paths: COMMAND_LONG 400 (normal + force), SET_MODE armed bit, then
  /// sustained RC_CHANNELS_OVERRIDE stick gestures (Mode-2 / Mode-1), including
  /// a combined SET_MODE + override hold until heartbeat shows armed.
  Future<CommandAck> arm({bool force = false}) async {
    if (_connection.heartbeatArmed) {
      return const CommandAck(command: MavCmd.componentArmDisarm, result: MavResult.accepted);
    }

    try {
      final forceFlags = force ? const [true] : const [false, true];
      for (final comp in const [_kppBroadcastComponent, 1]) {
        for (final useForce in forceFlags) {
          try {
            final ack = await sendCommand(
              command: MavCmd.componentArmDisarm,
              param1: 1,
              param2: useForce ? 21196 : 0,
              targetComponent: comp,
            );
            if (_connection.heartbeatArmed || await _waitArmed(const Duration(milliseconds: 800))) {
              return ack;
            }
          } on CommandException catch (error) {
            if (!_shouldFallbackToMode(error)) {
              rethrow;
            }
          }
        }
      }

      if (await _armViaSetMode()) {
        return const CommandAck(command: MavCmd.componentArmDisarm, result: MavResult.accepted);
      }
      if (await _armViaRcOverrideHold()) {
        return const CommandAck(command: MavCmd.componentArmDisarm, result: MavResult.accepted);
      }
      if (await _armViaCombinedHold()) {
        return const CommandAck(command: MavCmd.componentArmDisarm, result: MavResult.accepted);
      }

      // Pilot may already have armed on the TX while we were trying.
      if (_connection.heartbeatArmed) {
        return const CommandAck(command: MavCmd.componentArmDisarm, result: MavResult.accepted);
      }

      throw const CommandException(
        'App arm did not take yet. Retry Arm in the app, or arm with the transmitter '
        '(throttle low + yaw right) — both work. Need live link, Good GPS (≥6 sats), sensors OK.',
      );
    } finally {
      _releaseRcOverride();
    }
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

  /// Land / RTL entry. [setMode] already falls back when command 176 is rejected.
  Future<void> _setCopterMode(int customMode) async {
    await setMode(customMode);
  }

  Future<bool> _armViaSetMode() async {
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (DateTime.now().isBefore(deadline)) {
      final base = _connection.lastBaseMode | SetMode.flagSafetyArmed | SetMode.flagCustomModeEnabled;
      try {
        _connection.send(
          SetMode(
            targetSystem: _connection.targetSystem,
            baseMode: base & 0xFF,
            customMode: _connection.lastCustomMode,
          ),
        );
      } on FcLinkException {
        return false;
      }
      if (_connection.heartbeatArmed) {
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }
    return _connection.heartbeatArmed;
  }

  /// Sustained RC_CHANNELS_OVERRIDE stick-arm (app simulates TX arm gesture).
  Future<bool> _armViaRcOverrideHold() async {
    final sys = _connection.targetSystem;
    final gestures = <RcChannelsOverride>[
      RcChannelsOverride.stickArmMode2(targetSystem: sys),
      RcChannelsOverride.stickArmMode2(targetSystem: sys, throttleUs: 1100, yawUs: 1900),
      RcChannelsOverride.stickArmMode1(targetSystem: sys),
    ];
    for (final gesture in gestures) {
      if (await _holdOverrideUntilArmed(gesture, const Duration(seconds: 4))) {
        return true;
      }
    }
    return false;
  }

  /// SET_MODE armed bit + Mode-2 override together (strongest app-side path).
  Future<bool> _armViaCombinedHold() async {
    final sys = _connection.targetSystem;
    final gesture = RcChannelsOverride.stickArmMode2(targetSystem: sys);
    final release = RcChannelsOverride.release(targetSystem: sys);
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (DateTime.now().isBefore(deadline)) {
      final base = _connection.lastBaseMode | SetMode.flagSafetyArmed | SetMode.flagCustomModeEnabled;
      try {
        _connection.send(
          SetMode(
            targetSystem: sys,
            baseMode: base & 0xFF,
            customMode: _connection.lastCustomMode,
          ),
        );
        _connection.send(gesture);
        // Keep trying force arm while holding sticks.
        _connection.send(
          CommandLong(
            command: MavCmd.componentArmDisarm,
            targetSystem: sys,
            targetComponent: _kppBroadcastComponent,
            param1: 1,
            param2: 21196,
          ),
        );
      } on FcLinkException {
        break;
      }
      if (_connection.heartbeatArmed) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    try {
      _connection.send(release);
    } on FcLinkException {
      // ignore
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _connection.heartbeatArmed;
  }

  Future<bool> _holdOverrideUntilArmed(RcChannelsOverride gesture, Duration holdFor) async {
    final release = RcChannelsOverride.release(targetSystem: gesture.targetSystem);
    final deadline = DateTime.now().add(holdFor);
    while (DateTime.now().isBefore(deadline)) {
      try {
        _connection.send(gesture);
      } on FcLinkException {
        return false;
      }
      if (_connection.heartbeatArmed) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    try {
      _connection.send(release);
    } on FcLinkException {
      // ignore
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _connection.heartbeatArmed;
  }

  Future<bool> _waitArmed(Duration timeout) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (_connection.heartbeatArmed) {
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    return _connection.heartbeatArmed;
  }

  /// Drop GCS stick override so the transmitter owns the sticks again.
  void _releaseRcOverride() {
    try {
      _connection.send(
        RcChannelsOverride.release(targetSystem: _connection.targetSystem),
      );
    } on FcLinkException {
      // ignore — link may already be down
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
