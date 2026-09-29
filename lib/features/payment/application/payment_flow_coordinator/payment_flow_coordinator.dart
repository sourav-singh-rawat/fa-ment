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

  Stream<PaymentFlowEvent> get events => _paymentEvents.stream;

  String _createTimeoutTaskId(String key) => 'create-timeout-$key';
  String _pollTaskId(String key) => 'poll-$key';
  String _deadlineTaskId(String key) => 'deadline-$key';

  void dispose() {
    _stopTracking();
    _lastStatus = null;
    _paymentEvents.close();
  }

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

    _lastStatus = null;

    await _listenAsyncStatusUpdates(key);

    final timeoutId = _createTimeoutTaskId(key);
    _scheduler.scheduleOnce(timeoutId, _createTimeout, () {
      _dispatchEvent(
        CreateTimedOut(paymentAttempt, error: 'Create payment timeout'),
      );
    });

    try {
      await savePaymentAttempt(paymentAttempt);

      _gateway.mode = backendMode;

      final serverId = await _gateway.create(key);

      paymentAttempt = paymentAttempt.copyWith(serverId: serverId);

      _dispatchEvent(CreateSucceeded(paymentAttempt));
    } catch (error) {
      _dispatchEvent(CreateTimedOut(paymentAttempt, error: error.toString()));
    } finally {
      _scheduler.cancel(timeoutId);
    }
  }

  Future<PaymentStatus> requestStatus(String key) => _gateway.status(key);

  Future<void> waitAndConfirmStatus(String key, DateTime deadline) async {
    final remaining = deadline.difference(DateTime.now());

    if (remaining <= Duration.zero) {
      _reachDeadline();
      return;
    }

    _scheduleDeadline(key, remaining);

    await _checkStatus(key);

    if (hasTerminalStatus || _pollInterval > remaining) return;

    _schedulePolling(key);
  }

  void onAppBackground() => _stopTracking();

  void onAppResumed(String key, DateTime deadline) async {
    await _listenAsyncStatusUpdates(key);
    await waitAndConfirmStatus(key, deadline);
  }

  Future<void> savePaymentAttempt(Payment attempt) => _repository.save(attempt);

  Future<void> updatePaymentAttempt(Payment attempt) =>
      _repository.update(attempt);

  Future<void> _checkStatus(String key) async {
    final status = await requestStatus(key);
    _dispatchPaymentStatus(status);
  }

  void _schedulePolling(String key) {
    final pollId = _pollTaskId(key);

    _scheduler.schedulePeriodic(pollId, _pollInterval, () async {
      if (hasTerminalStatus) {
        _scheduler.cancel(pollId);
        return;
      }

      await _checkStatus(key);
    });
  }

  void _scheduleDeadline(String key, Duration duration) {
    _scheduler.scheduleOnce(_deadlineTaskId(key), duration, _reachDeadline);
  }

  void _reachDeadline() {
    _dispatchEvent(ConfirmingDeadlineReached());
    _stopTracking();
  }

  Future<void> _listenAsyncStatusUpdates(String key) async {
    await _statusUpdatesSubscription?.cancel();

    _statusUpdatesSubscription = _gateway.updates.listen((data) {
      if (data.$1 != key || hasTerminalStatus) return;

      if (data.$1 != key) return;

      _dispatchPaymentStatus(data.$2);
    });
  }

  void _dispatchPaymentStatus(PaymentStatus status) async {
    if (hasTerminalStatus) return;

    _lastStatus = status;
    if (!status.isTerminal) return;

    _dispatchEvent(TerminalStatus(status));
    _stopTracking();
  }

  void _stopTracking() {
    _scheduler.cancelAll();
    _statusUpdatesSubscription?.cancel();
    _statusUpdatesSubscription = null;
  }

  void _dispatchEvent(PaymentFlowEvent event) {
    _paymentEvents.add(event);
  }
}
