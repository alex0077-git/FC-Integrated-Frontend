import 'dart:typed_data';

/// A raw byte pipe to a flight controller (real serial port or simulator).
abstract interface class FcLink {
  /// Human-readable description, e.g. "COM3 @ 57600".
  String get label;

  Stream<Uint8List> get incoming;

  /// Opens the link. Throws [FcLinkException] if it cannot be opened.
  Future<void> open();

  void write(Uint8List bytes);

  Future<void> close();
}

/// Renames an existing link for UI (e.g. Bluetooth COM → "BT COM5 @ 57600").
class LabeledFcLink implements FcLink {
  LabeledFcLink(this.inner, this.label);

  final FcLink inner;

  @override
  final String label;

  @override
  Stream<Uint8List> get incoming => inner.incoming;

  @override
  Future<void> open() => inner.open();

  @override
  void write(Uint8List bytes) => inner.write(bytes);

  @override
  Future<void> close() => inner.close();
}

class FcLinkException implements Exception {
  const FcLinkException(this.message);

  final String message;

  @override
  String toString() => message;
}
