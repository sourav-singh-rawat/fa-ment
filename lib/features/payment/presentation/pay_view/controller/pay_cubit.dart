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
    show GatewayModeType;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show PaymentPending;
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:fave/shared/utils/async_state.dart' show AsyncState;

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
      List<Payment> transactions = await _paymentRepository.loadRecent();
      if (transactions.isEmpty) return;

      transactions = transactions.take(2).toList();

      emit(
        state.copyWith(
          transactions: AsyncState.success(data: [...transactions]),
        ),
      );

      //dummy delay for better UX
      await Future.delayed(const Duration(milliseconds: 1500));

      await _updatePendingStatus(transactions);
    } catch (error) {
      emit(
        state.copyWith(
          transactions: AsyncState.failure(error: "Opps, Something went wrong"),
        ),
      );
    }
  }

  Future<void> _updatePendingStatus(List<Payment> transactions) async {
    bool hasUpdate = false;
    for (var i = 0; i < transactions.length; i++) {
      if (transactions[i].status is! PaymentPending) continue;
      hasUpdate = true;

      final status = await _paymentFlowCoordinator.requestStatus(
        transactions[i].id,
      );

      transactions[i] = transactions[i].copyWith(status: status);
      await _paymentFlowCoordinator.updatePaymentAttempt(transactions[i]);
    }

    if (!hasUpdate) return;

    if (isClosed) return;
    emit(
      state.copyWith(transactions: AsyncState.success(data: [...transactions])),
    );
  }

  void onChangeBackendMode(GatewayModeType mode) {
    emit(state.copyWith(backendMode: mode));
  }

  void onChangeRecipient(String recipientId) {
    emit(state.copyWith(recipientId: recipientId));
  }

  void onChangeAmount(int value) {
    emit(state.copyWith(amount: value));
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
      emit(state.copyWith(createPaymentState: AsyncState.loading()));

      _paymentFlowCoordinator.createPayment(
        backendMode: state.backendMode,
        recipientId: state.recipientId,
        amount: state.amount!,
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
