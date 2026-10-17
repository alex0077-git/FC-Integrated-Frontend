import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/link/fc_link.dart';
import 'package:fuselage_kpp/data/link/serial_fc_link.dart';
import 'package:fuselage_kpp/data/session/fc_session.dart';

enum FcLinkStatus { disconnected, connecting, loadingParameters, connected, linkLost }

class FcConnectionState {
  const FcConnectionState({
    this.status = FcLinkStatus.disconnected,
    this.session,
    this.errorMessage,
    this.paramsReceived = 0,
    this.paramsTotal = 0,
  });

  final FcLinkStatus status;
  final FcSession? session;
  final String? errorMessage;
  final int paramsReceived;
  final int paramsTotal;

  bool get isBusy => status == FcLinkStatus.connecting || status == FcLinkStatus.loadingParameters;

  bool get hasSession => session != null;

  bool get isSimulator => session?.isSimulated ?? false;
}

/// Owns the single flight-controller session: connect, initial parameter
/// download, link-loss watchdog and disconnect.
class FcConnectionController extends Notifier<FcConnectionState> {
  static const Duration _watchdogInterval = Duration(seconds: 1);
  /// Wired USB: short grace — cable drops are usually hard failures.
  static const Duration _usbLinkLostAfter = Duration(seconds: 3);
  /// Bluetooth / WiFi TX: radio stalls of several seconds are common.
  static const Duration _transmitterLinkLostAfter = Duration(seconds: 12);

  Timer? _watchdog;

  /// The open session, kept outside [state] because Riverpod forbids reading
  /// state inside onDispose.
  FcSession? _openSession;

  @override
  FcConnectionState build() {
    ref.onDispose(() {
      _watchdog?.cancel();
      _openSession?.close();
    });
    return const FcConnectionState();
  }

  Future<void> connect(ConnectionSettings settings) async {
    await disconnect();
    state = const FcConnectionState(status: FcLinkStatus.connecting);
    // Let the Connecting spinner paint before a blocking BT COM open.
    await Future<void>.delayed(Duration.zero);
    final FcSession session;
    try {
      session = await _openWithBluetoothFallback(settings);
    } catch (error) {
      state = FcConnectionState(errorMessage: error.toString());
      return;
    }
    _openSession = session;
    state = FcConnectionState(status: FcLinkStatus.loadingParameters, session: session);
    await _downloadParameters(session);
    if (state.session == session) {
      _watchdog = Timer.periodic(_watchdogInterval, (_) => _checkLink(session));
    }
  }

  /// Bluetooth: if Incoming COM fails to open (semaphore timeout) or never
  /// replies, try the sibling Outgoing COM once. USB / WiFi unchanged.
  Future<FcSession> _openWithBluetoothFallback(ConnectionSettings settings) async {
    try {
      return await FcSession.open(settings);
    } on FcLinkException catch (firstError) {
      final alternate = settings.alternateBluetoothPort(ref.read(serialPortListerProvider));
      if (alternate == null) {
        rethrow;
      }
      return _openAlternateBluetooth(settings, alternate, firstError);
    } on FcConnectException catch (firstError) {
      final alternate = settings.alternateBluetoothPort(ref.read(serialPortListerProvider));
      if (alternate == null) {
        rethrow;
      }
      return _openAlternateBluetooth(settings, alternate, firstError);
    }
  }

  Future<FcSession> _openAlternateBluetooth(
    ConnectionSettings settings,
    ConnectionSettings alternate,
    Object firstError,
  ) async {
    developer.log(
      'BT ${settings.portName} failed ($firstError); retrying ${alternate.portName}',
      name: 'FcConnection',
    );
    try {
      return await FcSession.open(alternate);
    } catch (secondError) {
      throw FcConnectException(
        '$firstError\nAlso tried ${alternate.portName}: $secondError',
      );
    }
  }

  Future<void> reloadParameters() async {
    final session = state.session;
    if (session == null) {
      return;
    }
    state = FcConnectionState(status: FcLinkStatus.loadingParameters, session: session);
    await _downloadParameters(session);
  }

  Future<void> disconnect() async {
    _watchdog?.cancel();
    _watchdog = null;
    final session = _openSession;
    _openSession = null;
    state = const FcConnectionState();
    if (session != null) {
      await session.close();
    }
  }

  Future<void> _downloadParameters(FcSession session) async {
    String? error;
    try {
      await session.parameters.downloadAll(
        onProgress: (received, total) {
          if (state.session == session) {
            state = FcConnectionState(
              status: FcLinkStatus.loadingParameters,
              session: session,
              paramsReceived: received,
              paramsTotal: total,
            );
          }
        },
      );
      // After params are known, turn on position/GPS streams (SR0_* default to 0 on K++).
      await session.ensureTelemetryRates();
    } catch (e) {
      error = e.toString();
      if (session.isTransmitterLink && error.contains('did not send any parameters')) {
        error =
            'Bluetooth linked but the FC sent no parameters. '
            'Working setup used the Outgoing BT COM @ 57600 with aircraft powered — '
            'try the other Bluetooth COM if listed, or re-pair T12_055 in Windows.';
        _watchdog?.cancel();
        _watchdog = null;
        _openSession = null;
        await session.close();
        if (state.session == session || state.isBusy) {
          state = FcConnectionState(errorMessage: error);
        }
        return;
      }
    }
    if (state.session == session) {
      state = FcConnectionState(status: FcLinkStatus.connected, session: session, errorMessage: error);
    }
  }

  void _checkLink(FcSession session) {
    if (state.session != session || state.isBusy) {
      return;
    }
    final last = session.connection.lastPacketAt;
    final grace = session.isTransmitterLink ? _transmitterLinkLostAfter : _usbLinkLostAfter;
    final lost = last == null || DateTime.now().difference(last) > grace;
    final next = lost ? FcLinkStatus.linkLost : FcLinkStatus.connected;
    if (next != state.status) {
      state = FcConnectionState(status: next, session: session, errorMessage: state.errorMessage);
    }
  }
}

/// Lists the COM ports present on this PC. Overridden in tests, where the
/// native serial-port library is not available.
final serialPortListerProvider = Provider<List<SerialPortInfo> Function()>((ref) => SerialPortInfo.available);

final fcConnectionProvider = NotifierProvider<FcConnectionController, FcConnectionState>(FcConnectionController.new);

final fcSessionProvider = Provider<FcSession?>((ref) => ref.watch(fcConnectionProvider.select((s) => s.session)));
