import 'package:fave/features/payment/domain/entities/gateway_mode.dart'
    show GatewayModeType;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show
        PaymentStatus,
        PaymentSuccess,
        PaymentFailed,
        PaymentUnresolved,
        PaymentPending;
import 'package:fave/features/payment/domain/payment_gateway.dart'
    show PaymentGateway;
import 'package:fave_fake_backend/fave_fake_backend.dart'
    as bd
    show PaymentBackend, FakePaymentBackend, PaymentStatus, BackendMode;

class FakePaymentGatewayImpl implements PaymentGateway {
  final bd.PaymentBackend _backend;
  FakePaymentGatewayImpl({bd.PaymentBackend? backend})
    : _backend = backend ?? bd.FakePaymentBackend();

  @override
  set mode(GatewayModeType mode) {
    (_backend as bd.FakePaymentBackend).mode = mode.toBackendMode;
  }

  @override
  Future<String> create(String key) {
    return _backend.create(key);
  }

  @override
  Future<PaymentStatus> status(String key) async {
    try {
      final status = await _backend.status(key);
      return status.toAppPaymentStatus;
    } catch (_) {
      return PaymentUnresolved();
    }
  }

  @override
  Stream<(String, PaymentStatus)> get updates {
    return _backend.updates.map<(String, PaymentStatus)>(
      (push) => (push.key, push.status.toAppPaymentStatus),
    );
  }

  @override
  Future<bool> cancel(String key) {
    return _backend.cancel(key);
  }
}

extension on GatewayModeType {
  bd.BackendMode get toBackendMode {
    switch (this) {
      case GatewayModeType.success:
        return bd.BackendMode.success;
      case GatewayModeType.declined:
        return bd.BackendMode.declined;
      case GatewayModeType.lostResponse:
        return bd.BackendMode.lostResponse;
      case GatewayModeType.pendingForever:
        return bd.BackendMode.pendingForever;
      case GatewayModeType.flipAfterSuccess:
        return bd.BackendMode.flipAfterSuccess;
      case GatewayModeType.lateSuccess:
        return bd.BackendMode.lateSuccess;
    }
  }
}

extension on bd.PaymentStatus {
  PaymentStatus get toAppPaymentStatus {
    switch (this) {
      case bd.PaymentStatus.pending:
        return PaymentPending();
      case bd.PaymentStatus.success:
        return PaymentSuccess();
      case bd.PaymentStatus.failed:
      case bd.PaymentStatus.refunded:
        return PaymentFailed();
    }
  }
}
