enum GatewayMode {
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
