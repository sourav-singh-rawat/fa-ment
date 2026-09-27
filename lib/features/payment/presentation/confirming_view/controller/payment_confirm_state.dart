part of 'payment_confirm_cubit.dart';

@immutable
sealed class PaymentConfirmState {
  const PaymentConfirmState();
}

final class PaymentConfirmInitial extends PaymentConfirmState {}

final class PaymentFinalStatus extends PaymentConfirmState {
  final Payment payment;
  const new(this.payment);
}
