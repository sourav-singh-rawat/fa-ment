import 'dart:developer' show log;

import 'package:fave/features/payment/domain/entities/gateway_mode.dart'
    show GatewayMode;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show
        PaymentStatus,
        PaymentConfirming,
        PaymentSuccess,
        PaymentFailed,
        PaymentUnresolved;
import 'package:fave/features/payment/domain/payment_gateway.dart'
    show PaymentGateway;
import 'package:fave_fake_backend/fave_fake_backend.dart'
    as bd
    show PaymentBackend, FakePaymentBackend, PaymentStatus, BackendMode;

class SDKPaymentGatewayImpl implements PaymentGateway {
  final bd.PaymentBackend _backend;
  SDKPaymentGatewayImpl({bd.PaymentBackend? backend})
    : _backend = backend ?? bd.FakePaymentBackend();

  @override
  set mode(GatewayMode mode) {
    (_backend as bd.FakePaymentBackend).mode = mode.toBackendMode;
  }

  @override
  Future<String> create(String key) {
    return _backend.create(key);
  }

  @override
  Future<PaymentStatus> status(String key) async {
    final status = await _backend.status(key);
    return status.toAppPaymentStatus;
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

extension on GatewayMode {
  bd.BackendMode get toBackendMode {
    switch (this) {
      case GatewayMode.success:
        return bd.BackendMode.success;
      case GatewayMode.declined:
        return bd.BackendMode.declined;
      case GatewayMode.lostResponse:
        return bd.BackendMode.lostResponse;
      case GatewayMode.pendingForever:
        return bd.BackendMode.pendingForever;
      case GatewayMode.flipAfterSuccess:
        return bd.BackendMode.flipAfterSuccess;
      case GatewayMode.lateSuccess:
        return bd.BackendMode.lateSuccess;
    }
  }
}

extension on bd.PaymentStatus {
  PaymentStatus get toAppPaymentStatus {
    try {
      switch (this) {
        case bd.PaymentStatus.pending:
          return PaymentConfirming();
        case bd.PaymentStatus.success:
          return PaymentSuccess();
        case bd.PaymentStatus.failed:
        case bd.PaymentStatus.refunded:
          return PaymentFailed();
      }
    } catch (error) {
      log(error.toString());
      return PaymentUnresolved();
    }
  }
}
