import 'dart:async' show StreamSubscription;

import 'package:bloc/bloc.dart' show Cubit;
import 'package:equatable/equatable.dart' show Equatable;
import 'package:fave/features/payment/application/payment_flow_coordinator/payment_flow_coordinator.dart'
    show
        PaymentFlowCoordinator,
        PaymentFlowEvent,
        CreateTimedOut,
        CreateSucceeded;
import 'package:fave/features/payment/constant/gateway_modes.dart'
    show SeededGatewayModes;
import 'package:fave/features/payment/constant/recipients.dart'
    show SeededRecipients;
import 'package:fave/features/payment/domain/entities/gateway_mode.dart'
    show GatewayMode;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/entities/recipient.dart'
    show Recipient;
import 'package:fave/shared/utils/valid_type.dart';

part 'pay_state.dart';

class PayCubit extends Cubit<PayState> {
  final PaymentFlowCoordinator _paymentFlowCoordinator;
  late final StreamSubscription<PaymentFlowEvent> _paymentFlowEventSubscription;
  PayCubit(this._paymentFlowCoordinator) : super(PayState.init()) {
    _paymentFlowEventSubscription = _paymentFlowCoordinator.events.listen(
      _listenPaymentFlowEvents,
    );
  }

  Payment? _attempt;

  void onChangeBackendMode(GatewayMode mode) {
    emit(state.copyWith(backendMode: mode));
  }

  void onChangeRecipient(Recipient recipient) {
    emit(state.copyWith(recipient: recipient));
  }

  void onChangeAmount(String value) {
    emit(
      state.copyWith(
        amount: state.amount.copyWith(value: value, errorText: value.validate),
      ),
    );
  }

  void onChangeNote(String note) {
    emit(state.copyWith(note: note));
  }

  void onPressPay() {
    if (_attempt != null) {
      return _onCheckStatus();
    }
    return _onCreatePayment();
  }

  void _onCreatePayment() {
    try {
      final parsed = int.tryParse(state.amount.value);

      emit(state.copyWith(status: .sending));

      _paymentFlowCoordinator.createPayment(
        recipientId: state.recipient.id,
        amount: parsed!,
        note: state.note,
      );
    } catch (error) {
      //TODO: throw snack-bar event
    }
  }

  void _onCheckStatus() {
    //TODO: throw navigation with attempt
  }

  void _listenPaymentFlowEvents(PaymentFlowEvent event) {
    switch (event) {
      case CreateTimedOut():
        return _onCreatePaymentTimeout(event.paymentAttempt, event.error);
      case CreateSucceeded():
        return _onCreatePaymentSucceeded(event.paymentAttempt);
      default:
        return;
    }
  }

  void _onCreatePaymentTimeout(Payment attempt, String error) {
    emit(state.copyWith(status: .idle));
    _attempt = attempt;
    //TODO: throw snack-bar event
  }

  void _onCreatePaymentSucceeded(Payment attempt) {
    _attempt = attempt;
    //TODO: throw navigation event
  }

  @override
  Future<void> close() {
    _attempt = null;
    _paymentFlowEventSubscription.cancel();
    return super.close();
  }
}

extension on String {
  String get validate {
    if (isEmpty) return '';
    final parsed = int.tryParse(this);
    if (parsed == null) return 'Opps, Something wrong.';
    if (parsed < 1) return 'Enter at least ₹1';
    if (parsed > 100000) {
      return 'UPI payments are capped at ₹1,00,000 per transaction';
    }
    return '';
  }
}
