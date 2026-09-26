import 'package:fave/features/payment/data/i.fake_payment_gateway.dart'
    show FakePaymentGatewayImpl;
import 'package:fave/features/payment/domain/entities/gateway_mode.dart'
    show GatewayModeType;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show PaymentStatus;

abstract class PaymentGateway {
  const PaymentGateway._();

  factory PaymentGateway() => FakePaymentGatewayImpl();

  set mode(GatewayModeType mode);

  Future<String> create(String key);

  Future<PaymentStatus> status(String key);

  Stream<(String, PaymentStatus)> get updates;

  Future<bool> cancel(String key);
}
