import 'package:equatable/equatable.dart';

enum GatewayModeType {
  /// pending, pending, success.
  success,

  /// pending, failed.
  declined,

  /// B1 — create never returns. status(key): pending, then success.
  lostResponse,

  /// B2 — status returns pending and never stops.
  pendingForever,

  /// B3 — pending, success; then a push saying failed, [flipDelay] later.
  flipAfterSuccess,

  /// B4 — pending, failed; then a push saying success, [lateSuccessDelay] later.
  lateSuccess,
}

class GatewayMode extends Equatable {
  final GatewayModeType type;
  final String title;
  final String description;

  const new({
    required this.type,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [type];
}
