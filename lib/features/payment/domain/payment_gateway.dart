import 'package:fave/features/payment/data/i.sdk_payment_gateway.dart'
    show SDKPaymentGatewayImpl;
import 'package:fave/features/payment/domain/entities/gateway_mode.dart'
    show GatewayMode;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show PaymentStatus;

abstract class PaymentGateway {
  const PaymentGateway._();

  factory PaymentGateway() => SDKPaymentGatewayImpl();

  set mode(GatewayMode mode);

  Future<String> create(String key);

  Future<PaymentStatus> status(String key);

  Stream<(String, PaymentStatus)> get updates;

  Future<bool> cancel(String key);
}
