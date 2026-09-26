import 'package:fave/features/payment/data/i.sdk_payment_gateway.dart'
    show SDKPaymentGatewayImpl;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show PaymentStatus;

abstract class PaymentGateway {
  const PaymentGateway._();

  factory PaymentGateway() => SDKPaymentGatewayImpl();

  Future<String> create(String key);

  Future<PaymentStatus> status(String key);

  Stream<(String, PaymentStatus)> get updates;

  Future<bool> cancel(String key);
}
