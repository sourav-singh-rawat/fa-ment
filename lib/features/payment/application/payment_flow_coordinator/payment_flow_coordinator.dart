import 'dart:async' show StreamSubscription, StreamController;

import 'package:fave/features/payment/domain/entities/payment.dart';
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show PaymentStatus, PaymentFailed, PaymentSuccess;
import 'package:fave/features/payment/domain/payment_gateway.dart'
    show PaymentGateway;
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:fave/shared/modules/id_generator/id_generator.dart'
    show IdGenerator;
import 'package:fave/shared/modules/task_scheduler/task_scheduler.dart'
    show TaskScheduler;
import 'package:rxdart/rxdart.dart' show BehaviorSubject;

part 'payment_flow_events.dart';

const _createTimeout = Duration(seconds: 5);
const _confirmingDeadline = Duration(seconds: 10);
const _pollOffsets = [
  Duration(seconds: 2),
  Duration(seconds: 4),
  Duration(seconds: 6),
  Duration(seconds: 8),
];
const _terminalExitDuration = Duration(milliseconds: 250);

//TODO: should be created new object always on restart flow
class PaymentFlowCoordinator {
  final IdGenerator _keyGenerator;
  final PaymentRepository _repository;
  final PaymentGateway _gateway;
  final TaskScheduler _scheduler;

  final StreamController<PaymentFlowEvent> _paymentEvents;

  final BehaviorSubject<PaymentStatus> _statusSubject;
  StreamSubscription<(String, PaymentStatus)>? _statusUpdatesSubscription;

  String? _activeKey;

  new({
    required this._keyGenerator,
    required this._repository,
    required this._gateway,
    required this._scheduler,
  }) : _paymentEvents = StreamController<PaymentFlowEvent>.broadcast(),
       _statusSubject = BehaviorSubject();

  void dispose() {
    _statusUpdatesSubscription?.cancel();
    _scheduler.cancelAll();
    _statusSubject.close();
  }

  Stream<PaymentFlowEvent> get events => _paymentEvents.stream;

  //TODO: check if need to exposed or how to expose status one at a time
  // Stream<PaymentStatus> get statusUpdates => _statusSubject.stream;

  void createPayment({
    required String recipientId,
    required int amount,
    String? note,
  }) async {
    final key = _keyGenerator.generate();
    _activeKey = key;

    Payment paymentAttempt = Payment.create(
      key: key,
      recipientId: recipientId,
      amount: amount,
      note: note,
    );

    await _listenAsyncStatusUpdates();

    _scheduler.scheduleOnce('create-timeout-$key', _createTimeout, () {
      _dispatchEvent(
        CreateTimedOut(paymentAttempt, error: "Create payment timeout"),
      );
    });

    try {
      final serverId = await _gateway.create(key);
      _scheduler.cancel('create-timeout-$key');

      paymentAttempt = paymentAttempt.copyWith(serverId: serverId);

      _dispatchEvent(CreateSucceeded(paymentAttempt));

      await _repository.save(paymentAttempt);
    } catch (error) {
      if (_activeKey != key) return;
      _scheduler.cancel('create-timeout-$key');
      _dispatchEvent(CreateTimedOut(paymentAttempt, error: error.toString()));
    }
  }

  void confirm() {}

  Future<void> _listenAsyncStatusUpdates() async {
    await _statusUpdatesSubscription?.cancel();
    _statusUpdatesSubscription = _gateway.updates.listen((data) {
      if (data.$1 != _activeKey) return;
      switch (_statusSubject.value) {
        //TODO: need to handle this over a listen- as it can be a result of polling/one-time-check too
        case PaymentSuccess():
        case PaymentFailed():
          return;
        default:
          _statusSubject.add(data.$2);
      }
    });
  }

  void _dispatchEvent(PaymentFlowEvent event) {
    _paymentEvents.add(event);
  }
}
