import 'dart:async' show StreamSubscription;

import 'package:bloc/bloc.dart' show Cubit;
import 'package:fave/features/payment/application/payment_flow_coordinator/payment_flow_coordinator.dart'
    show
        PaymentFlowCoordinator,
        PaymentFlowEvent,
        ConfirmingDeadlineReached,
        TerminalStatus;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show PaymentStatus, PaymentPending;
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:meta/meta.dart' show immutable;

part 'payment_confirm_state.dart';

const kConfirmingDeadlineDuration = Duration(seconds: 10);

class PaymentConfirmCubit extends Cubit<PaymentConfirmState> {
  final PaymentFlowCoordinator _paymentFlowCoordinator;
  final PaymentRepository _repository;
  Payment _paymentAttempt;
  late final StreamSubscription<PaymentFlowEvent> _paymentFlowEventSubscription;
  late final DateTime _deadlineAt;
  PaymentConfirmCubit({
    required this._paymentFlowCoordinator,
    required this._repository,
    required this._paymentAttempt,
  }) : super(PaymentConfirmInitial()) {
    _paymentFlowEventSubscription = _paymentFlowCoordinator.events.listen(
      _listenPaymentFlowEvents,
    );
  }

  DateTime get confirmingDeadlineAt => _deadlineAt;

  void startConfirming() {
    _deadlineAt = DateTime.now().add(kConfirmingDeadlineDuration);
    _paymentFlowCoordinator.waitAndConfirmStatus(
      _paymentAttempt.id,
      _deadlineAt,
    );
  }

  void onAppBackgrounded() {
    _paymentFlowCoordinator.onAppBackground();
  }

  void onAppResumed() {
    _paymentFlowCoordinator.onAppResumed(_paymentAttempt.id, _deadlineAt);
  }

  void _listenPaymentFlowEvents(PaymentFlowEvent event) {
    switch (event) {
      case TerminalStatus():
        return _onReceiveStatus(event.status);
      case ConfirmingDeadlineReached():
        return _onReceiveStatus(PaymentPending());
      default:
        return;
    }
  }

  void _onReceiveStatus(PaymentStatus status) {
    _paymentAttempt = _paymentAttempt.copyWith(status: status);

    _repository.update(_paymentAttempt);

    emit(PaymentFinalStatus(_paymentAttempt));
  }

  @override
  Future<void> close() {
    _paymentFlowEventSubscription.cancel();
    return super.close();
  }
}
