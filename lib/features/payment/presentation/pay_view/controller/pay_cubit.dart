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
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:fave/shared/utils/async_state.dart' show AsyncState;
import 'package:fave/shared/utils/valid_state.dart';

part 'pay_state.dart';

class PayCubit extends Cubit<PayState> {
  final PaymentFlowCoordinator _paymentFlowCoordinator;
  final PaymentRepository _paymentRepository;
  late final StreamSubscription<PaymentFlowEvent> _paymentFlowEventSubscription;
  PayCubit({
    required this._paymentFlowCoordinator,
    required this._paymentRepository,
  }) : super(PayState.init()) {
    _paymentFlowEventSubscription = _paymentFlowCoordinator.events.listen(
      _listenPaymentFlowEvents,
    );
  }

  Payment? _attempt;

  void fetchRecentTransactions() async {
    try {
      final transactions = await _paymentRepository.loadRecent();
      emit(
        state.copyWith(
          transactions: AsyncState.success(data: transactions.take(2).toList()),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          transactions: AsyncState.failure(error: "Opps, Something went wrong"),
        ),
      );
    }
  }

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
    if (_attempt != null) return _onCheckStatus(_attempt!);

    return _onCreatePayment();
  }

  void _onCreatePayment() {
    try {
      final parsed = int.tryParse(state.amount.value);

      emit(state.copyWith(createPaymentState: AsyncState.loading()));

      _paymentFlowCoordinator.createPayment(
        backendMode: state.backendMode.type,
        recipientId: state.recipient.id,
        amount: parsed!,
        note: state.note,
      );
    } catch (error) {
      emit(
        state.copyWith(
          createPaymentState: AsyncState.failure(error: error.toString()),
        ),
      );
    }
  }

  void _onCheckStatus(Payment attempt) {
    emit(state.copyWith(createPaymentState: AsyncState.partial(data: attempt)));
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
    emit(state.copyWith(createPaymentState: AsyncState.failure(error: error)));
    _attempt = attempt;
  }

  void _onCreatePaymentSucceeded(Payment attempt) {
    emit(state.copyWith(createPaymentState: AsyncState.success(data: attempt)));
    _attempt = attempt;
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
