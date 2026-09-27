part of 'payment_flow_coordinator.dart';

sealed class PaymentFlowEvent {
  const PaymentFlowEvent();
}

final class CreateTimedOut extends PaymentFlowEvent {
  final Payment paymentAttempt;
  final String error;
  const CreateTimedOut(this.paymentAttempt, {required this.error});
}

final class CreateSucceeded extends PaymentFlowEvent {
  final Payment paymentAttempt;
  const CreateSucceeded(this.paymentAttempt);
}
