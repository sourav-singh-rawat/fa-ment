import 'package:fave/features/payment/domain/entities/gateway_mode.dart'
    show GatewayMode, GatewayModeType;
import 'package:fave/shared/constants/symbols.dart' show kInterPunctCharater;

class SeededGatewayModes {
  const SeededGatewayModes._();

  static const List<GatewayMode> all = [
    GatewayMode(
      type: GatewayModeType.success,
      title: "Success",
      description: "pending, pending, success — about 4 s",
    ),
    GatewayMode(
      type: GatewayModeType.declined,
      title: "Declined",
      description: "pending, failed",
    ),
    GatewayMode(
      type: GatewayModeType.lostResponse,
      title: "B1 $kInterPunctCharater Lost response",
      description: "create hangs; status(key) says pending, then success",
    ),
    GatewayMode(
      type: GatewayModeType.pendingForever,
      title: "B2 $kInterPunctCharater Pending forever",
      description: "pending, pending, pending…",
    ),
    GatewayMode(
      type: GatewayModeType.flipAfterSuccess,
      title: "B3 $kInterPunctCharater Flip after success",
      description:
          "pending, success $kInterPunctCharater push: failed, 300 ms later",
    ),
    GatewayMode(
      type: GatewayModeType.lateSuccess,
      title: "B4 $kInterPunctCharater Late success",
      description:
          "pending, failed $kInterPunctCharater push: success, 2 min later",
    ),
  ];

  static GatewayMode byType(GatewayModeType type) {
    return SeededGatewayModes.all.firstWhere((e) => e.type == type);
  }

  static GatewayMode get defaultMode => all.first;
}
