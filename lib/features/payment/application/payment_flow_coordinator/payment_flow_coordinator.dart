import 'dart:async' show StreamSubscription, StreamController;

import 'package:fave/features/payment/domain/entities/gateway_mode.dart'
    show GatewayModeType;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show PaymentStatus;
import 'package:fave/features/payment/domain/payment_gateway.dart'
    show PaymentGateway;
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:fave/shared/modules/id_generator/id_generator.dart'
    show IdGenerator;
import 'package:fave/shared/modules/task_scheduler/task_scheduler.dart'
    show TaskScheduler;

part 'payment_flow_events.dart';

const _createTimeout = Duration(seconds: 5);
const _pollInterval = Duration(seconds: 2);

class PaymentFlowCoordinator {
  final IdGenerator _keyGenerator;
  final PaymentRepository _repository;
  final PaymentGateway _gateway;
  final TaskScheduler _scheduler;

  final StreamController<PaymentFlowEvent> _paymentEvents;

  StreamSubscription<(String, PaymentStatus)>? _statusUpdatesSubscription;

  PaymentStatus? _lastStatus;

  new({
    required this._keyGenerator,
    required this._repository,
    required this._gateway,
    required this._scheduler,
  }) : _paymentEvents = StreamController<PaymentFlowEvent>.broadcast();

  bool get hasTerminalStatus => _lastStatus?.isTerminal ?? false;

  void dispose() {
    _statusUpdatesSubscription?.cancel();
    _scheduler.cancelAll();
    _lastStatus = null;
  }

  Stream<PaymentFlowEvent> get events => _paymentEvents.stream;

  void createPayment({
    required GatewayModeType backendMode,
    required String recipientId,
    required int amount,
    String? note,
  }) async {
    final key = _keyGenerator.generate();

    Payment paymentAttempt = Payment.create(
      key: key,
      recipientId: recipientId,
      amount: amount,
      note: note,
    );

    await _listenAsyncStatusUpdates(key);

    _scheduler.scheduleOnce('create-timeout-$key', _createTimeout, () {
      _dispatchEvent(
        CreateTimedOut(paymentAttempt, error: "Create payment timeout"),
      );
    });

    try {
      await _repository.save(paymentAttempt);

      _gateway.mode = backendMode;

      final serverId = await _gateway.create(key);
      _scheduler.cancel('create-timeout-$key');

      paymentAttempt = paymentAttempt.copyWith(serverId: serverId);

      _dispatchEvent(CreateSucceeded(paymentAttempt));
    } catch (error) {
      _scheduler.cancel('create-timeout-$key');
      _dispatchEvent(CreateTimedOut(paymentAttempt, error: error.toString()));
    }
  }

  Future<PaymentStatus> requestStatus(String key) async {
    final status = await _gateway.status(key);
    return status;
  }

  void waitAndConfirmStatus(String key, DateTime deadline) async {
    final remaining = deadline.difference(DateTime.now());

    if (remaining <= Duration.zero) {
      _dispatchEvent(ConfirmingDeadlineReached());
      return;
    }

    _scheduleDeadline(key, remaining);

    final status = await requestStatus(key);
    _dispatchPaymentStatus(key, status);

    if (_pollInterval > remaining) return;

    _schedulePolling(key);
  }

  void onAppBackground() {
    _scheduler.cancelAll();
    _statusUpdatesSubscription?.cancel();
  }

  void onAppResumed(String key, DateTime deadline) async {
    await _listenAsyncStatusUpdates(key);
    waitAndConfirmStatus(key, deadline);
  }

  void _schedulePolling(String key) {
    _scheduler.schedulePeriodic('poll-$key', _pollInterval, () async {
      if (hasTerminalStatus) {
        _scheduler.cancel('poll-$key');
        return;
      }

      final status = await requestStatus(key);
      _dispatchPaymentStatus(key, status);
    });
  }

  void _scheduleDeadline(String key, Duration duration) {
    _scheduler.scheduleOnce('deadline-$key', duration, () {
      _dispatchEvent(ConfirmingDeadlineReached());
    });
  }

  Future<void> _listenAsyncStatusUpdates(String key) async {
    await _statusUpdatesSubscription?.cancel();
    _statusUpdatesSubscription = _gateway.updates.listen((data) {
      if (hasTerminalStatus) {
        _statusUpdatesSubscription?.cancel();
        return;
      }

      if (data.$1 != key) return;
      _dispatchPaymentStatus(key, data.$2);
    });
  }

  void _dispatchPaymentStatus(String key, PaymentStatus status) async {
    _lastStatus = status;
    if (!status.isTerminal) return;

    _dispatchEvent(TerminalStatus(status));
    _scheduler.cancelAll();
    _statusUpdatesSubscription?.cancel();
  }

  void _dispatchEvent(PaymentFlowEvent event) {
    _paymentEvents.add(event);
  }
}
