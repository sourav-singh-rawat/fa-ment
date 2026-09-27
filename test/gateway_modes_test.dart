import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:fave/features/payment/application/payment_flow_coordinator/payment_flow_coordinator.dart'
    show
        PaymentFlowCoordinator,
        PaymentFlowEvent,
        CreateSucceeded,
        TerminalStatus,
        CreateTimedOut,
        ConfirmingDeadlineReached;
import 'package:fave/features/payment/domain/entities/gateway_mode.dart'
    show GatewayModeType;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show PaymentStatus, PaymentPending, PaymentSuccess, PaymentFailed;
import 'package:fave/features/payment/domain/payment_gateway.dart'
    show PaymentGateway;
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:fave/shared/modules/id_generator/id_generator.dart'
    show IdGenerator;
import 'package:fave/shared/modules/task_scheduler/task_scheduler.dart'
    show TaskScheduler;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class MockPaymentRepository extends Mock implements PaymentRepository {}

class MockIdGenerator extends Mock implements IdGenerator {}

/// A scriptable TaskScheduler that executes callbacks synchronously when the
/// test explicitly asks it to, instead of relying on dart:async Timer.
/// This keeps coordinator tests deterministic and independent of real time.
class ManualTaskScheduler implements TaskScheduler {
  final Map<String, void Function()> _once = {};
  final Map<String, void Function()> _periodic = {};

  @override
  void scheduleOnce(String key, Duration delay, void Function() callback) {
    _once[key] = callback;
  }

  @override
  void schedulePeriodic(
    String key,
    Duration interval,
    void Function() callback,
  ) {
    _periodic[key] = callback;
  }

  @override
  void cancel(String key) {
    _once.remove(key);
    _periodic.remove(key);
  }

  @override
  void cancelAll() {
    _once.clear();
    _periodic.clear();
  }

  bool isOnceScheduled(String key) => _once.containsKey(key);
  bool isPeriodicScheduled(String key) => _periodic.containsKey(key);

  void fireOnce(String key) {
    final cb = _once[key];
    expect(cb, isNotNull, reason: 'Expected a scheduled once-task for "$key"');
    cb!();
  }

  void firePeriodic(String key) {
    final cb = _periodic[key];
    expect(
      cb,
      isNotNull,
      reason: 'Expected a scheduled periodic-task for "$key"',
    );
    cb!();
  }
}

/// In-memory PaymentGateway whose behavior is scripted per GatewayModeType,
/// mirroring the six SeededGatewayModes scenarios documented in
/// constant/gateway_modes.dart. Using a script (rather than a live fake
/// backend + real Timers) keeps coordinator/cubit tests fast and deterministic.
class ScriptedFakeGateway implements PaymentGateway {
  GatewayModeType? _mode;
  final _updatesController =
      StreamController<(String, PaymentStatus)>.broadcast();

  Completer<String>? _pendingCreate;
  final List<Future<PaymentStatus> Function()> _statusScript = [];
  int _statusCallIndex = 0;

  @override
  set mode(GatewayModeType value) => _mode = value;

  GatewayModeType? get mode => _mode;

  @override
  Stream<(String, PaymentStatus)> get updates => _updatesController.stream;

  void pushUpdate(String key, PaymentStatus status) {
    _updatesController.add((key, status));
  }

  /// Configures create() to never resolve (simulates B1 lost response / B2 pending forever's create leg).
  void hangCreate() {
    _pendingCreate = Completer<String>();
  }

  void completeCreate(String serverId) {
    _pendingCreate?.complete(serverId);
  }

  void failCreate(Object error) {
    _pendingCreate?.completeError(error);
  }

  @override
  Future<String> create(String key) {
    if (_pendingCreate != null) return _pendingCreate!.future;
    return Future.value('server-$key');
  }

  /// Queue successive responses for status(); each call to status() consumes
  /// the next entry, repeating the last entry once exhausted.
  void queueStatuses(List<PaymentStatus> statuses) {
    _statusScript
      ..clear()
      ..addAll(
        statuses.map(
          (s) =>
              () async => s,
        ),
      );
    _statusCallIndex = 0;
  }

  @override
  Future<PaymentStatus> status(String key) async {
    if (_statusScript.isEmpty) return PaymentPending();
    final idx = _statusCallIndex < _statusScript.length
        ? _statusCallIndex
        : _statusScript.length - 1;
    _statusCallIndex++;
    return _statusScript[idx]();
  }

  @override
  Future<bool> cancel(String key) async => true;

  void dispose() => _updatesController.close();
}

class MockPayment extends Fake implements Payment {}

const recipientId = 'recipient-1';
const amount = 500;
const note = 'test note';
const key = 'fixed-key-123';

Payment buildPayment({PaymentStatus? status}) {
  return Payment.create(
    key: key,
    recipientId: recipientId,
    amount: amount,
    note: note,
  ).copyWith(status: status);
}

void main() {
  late MockPaymentRepository repository;
  late MockIdGenerator idGenerator;
  late ManualTaskScheduler scheduler;
  late ScriptedFakeGateway gateway;
  late PaymentFlowCoordinator coordinator;

  setUpAll(() {
    registerFallbackValue(buildPayment());
  });

  setUp(() {
    repository = MockPaymentRepository();
    idGenerator = MockIdGenerator();
    scheduler = ManualTaskScheduler();
    gateway = ScriptedFakeGateway();

    when(() => idGenerator.generate()).thenReturn(key);
    when(() => repository.save(any())).thenAnswer((_) async {});
    when(() => repository.update(any())).thenAnswer((_) async {});

    coordinator = PaymentFlowCoordinator(
      keyGenerator: idGenerator,
      repository: repository,
      gateway: gateway,
      scheduler: scheduler,
    );
  });

  tearDown(() {
    coordinator.dispose();
    gateway.dispose();
  });

  group('GatewayModeType.success', () {
    test(
      'sets gateway.mode to success and dispatches CreateSucceeded on create()',
      () async {
        final events = <PaymentFlowEvent>[];
        final sub = coordinator.events.listen(events.add);

        coordinator.createPayment(
          backendMode: GatewayModeType.success,
          recipientId: recipientId,
          amount: amount,
          note: note,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(gateway.mode, GatewayModeType.success);
        expect(events, [isA<CreateSucceeded>()]);
        expect(
          (events.single as CreateSucceeded).paymentAttempt.serverId,
          'server-$key',
        );
        // create-timeout must be cancelled after successful create.
        expect(scheduler.isOnceScheduled('create-timeout-$key'), isFalse);

        await sub.cancel();
      },
    );

    test('resolves pending -> pending -> success via status polling', () {
      fakeAsync((async) {
        gateway.queueStatuses([
          PaymentPending(),
          PaymentPending(),
          PaymentSuccess(),
        ]);

        final events = <PaymentFlowEvent>[];
        coordinator.events.listen(events.add);

        coordinator.waitAndConfirmStatus(
          key,
          DateTime.now().add(const Duration(seconds: 10)),
        );
        async.flushMicrotasks();

        // First status() call -> pending, not terminal, polling scheduled.
        expect(scheduler.isPeriodicScheduled('poll-$key'), isTrue);

        scheduler.firePeriodic('poll-$key');
        async.flushMicrotasks();
        expect(events, isEmpty); // still pending

        scheduler.firePeriodic('poll-$key');
        async.flushMicrotasks();

        expect(events, [isA<TerminalStatus>()]);
        expect((events.single as TerminalStatus).status, isA<PaymentSuccess>());
      });
    });
  });

  group('GatewayModeType.declined', () {
    test('sets gateway.mode to declined', () async {
      coordinator.createPayment(
        backendMode: GatewayModeType.declined,
        recipientId: recipientId,
        amount: amount,
      );
      await Future<void>.delayed(Duration.zero);
      expect(gateway.mode, GatewayModeType.declined);
    });

    test(
      'dispatches TerminalStatus(PaymentFailed) after pending then failed',
      () {
        fakeAsync((async) {
          gateway.queueStatuses([PaymentPending(), PaymentFailed()]);

          final events = <PaymentFlowEvent>[];
          coordinator.events.listen(events.add);

          coordinator.waitAndConfirmStatus(
            key,
            DateTime.now().add(const Duration(seconds: 10)),
          );
          async.flushMicrotasks();
          expect(events, isEmpty);

          scheduler.firePeriodic('poll-$key');
          async.flushMicrotasks();

          expect(events, [isA<TerminalStatus>()]);
          expect(
            (events.single as TerminalStatus).status,
            isA<PaymentFailed>(),
          );
          // Polling must stop once terminal.
          expect(scheduler.isPeriodicScheduled('poll-$key'), isFalse);
        });
      },
    );
  });

  group('GatewayModeType.lostResponse (B1)', () {
    test('create() hang triggers CreateTimedOut via scheduler timeout', () {
      fakeAsync((async) {
        gateway.hangCreate();

        final events = <PaymentFlowEvent>[];
        coordinator.events.listen(events.add);

        coordinator.createPayment(
          backendMode: GatewayModeType.lostResponse,
          recipientId: recipientId,
          amount: amount,
        );
        async.flushMicrotasks();

        expect(gateway.mode, GatewayModeType.lostResponse);
        expect(scheduler.isOnceScheduled('create-timeout-$key'), isTrue);
        expect(events, isEmpty); // create() still hanging

        scheduler.fireOnce('create-timeout-$key');
        async.flushMicrotasks();

        expect(events, [isA<CreateTimedOut>()]);
        expect(
          (events.single as CreateTimedOut).error,
          'Create payment timeout',
        );
      });
    });

    test('status polling still resolves pending -> success independent of hung create()', () {
      fakeAsync((async) {
        gateway.hangCreate();
        gateway.queueStatuses([PaymentPending(), PaymentSuccess()]);

        final events = <PaymentFlowEvent>[];
        coordinator.events.listen(events.add);

        coordinator.waitAndConfirmStatus(
          key,
          DateTime.now().add(const Duration(seconds: 10)),
        );
        async.flushMicrotasks();

        scheduler.firePeriodic('poll-$key');
        async.flushMicrotasks();

        expect(events, [isA<TerminalStatus>()]);
        expect((events.single as TerminalStatus).status, isA<PaymentSuccess>());
      });
    });
  });

  group('GatewayModeType.pendingForever (B2)', () {
    test('never dispatches TerminalStatus; polling keeps rescheduling', () {
      fakeAsync((async) {
        gateway.queueStatuses([
          PaymentPending(),
          PaymentPending(),
          PaymentPending(),
        ]);

        final events = <PaymentFlowEvent>[];
        coordinator.events.listen(events.add);

        coordinator.waitAndConfirmStatus(
          key,
          DateTime.now().add(const Duration(seconds: 30)),
        );
        async.flushMicrotasks();

        for (var i = 0; i < 3; i++) {
          scheduler.firePeriodic('poll-$key');
          async.flushMicrotasks();
        }

        expect(events, isEmpty);
        expect(coordinator.hasTerminalStatus, isFalse);
        expect(scheduler.isPeriodicScheduled('poll-$key'), isTrue);
      });
    });

    test('ConfirmingDeadlineReached fires once the deadline elapses with no terminal status', () {
      fakeAsync((async) {
        gateway.queueStatuses([PaymentPending()]);
        final deadline = DateTime.now().add(const Duration(seconds: 5));

        final events = <PaymentFlowEvent>[];
        coordinator.events.listen(events.add);

        coordinator.waitAndConfirmStatus(key, deadline);
        async.flushMicrotasks();

        scheduler.fireOnce('deadline-$key');
        async.flushMicrotasks();

        expect(events.whereType<ConfirmingDeadlineReached>(), hasLength(1));
      });
    });
  });

  group('GatewayModeType.flipAfterSuccess (B3)', () {
    test(
      'polling reaches success terminal status and ignores late push flip',
      () {
        fakeAsync((async) {
          gateway.queueStatuses([PaymentPending(), PaymentSuccess()]);

          final events = <PaymentFlowEvent>[];
          coordinator.events.listen(events.add);

          coordinator.createPayment(
            backendMode: GatewayModeType.flipAfterSuccess,
            recipientId: recipientId,
            amount: amount,
          );
          async.flushMicrotasks();

          coordinator.waitAndConfirmStatus(
            key,
            DateTime.now().add(const Duration(seconds: 10)),
          );
          async.flushMicrotasks();

          scheduler.firePeriodic('poll-$key');
          async.flushMicrotasks();

          expect(events.whereType<TerminalStatus>(), hasLength(1));
          expect(
            (events.whereType<TerminalStatus>().single).status,
            isA<PaymentSuccess>(),
          );

          // The push arrives 300ms later claiming "failed" — coordinator must
          // ignore it because hasTerminalStatus is already true.
          gateway.pushUpdate(key, PaymentFailed());
          async.elapse(const Duration(milliseconds: 300));
          async.flushMicrotasks();

          expect(events.whereType<TerminalStatus>(), hasLength(1));
          expect(
            (events.whereType<TerminalStatus>().single).status,
            isA<PaymentSuccess>(),
            reason: 'Late push after terminal status must not override result',
          );
        });
      },
    );
  });

  group('GatewayModeType.lateSuccess (B4)', () {
    test(
      'polling terminates on failed before the late success push arrives',
      () {
        fakeAsync((async) {
          gateway.queueStatuses([PaymentPending(), PaymentFailed()]);

          final events = <PaymentFlowEvent>[];
          coordinator.events.listen(events.add);

          coordinator.waitAndConfirmStatus(
            key,
            DateTime.now().add(const Duration(minutes: 5)),
          );
          async.flushMicrotasks();

          scheduler.firePeriodic('poll-$key');
          async.flushMicrotasks();

          expect(events.whereType<TerminalStatus>(), hasLength(1));
          expect(
            (events.whereType<TerminalStatus>().single).status,
            isA<PaymentFailed>(),
          );

          // Late success push after 2 minutes is ignored — already terminal.
          gateway.pushUpdate(key, PaymentSuccess());
          async.elapse(const Duration(minutes: 2));
          async.flushMicrotasks();

          expect(
            events.whereType<TerminalStatus>(),
            hasLength(1),
            reason:
                'Late-arriving success push must not resurrect a terminal flow',
          );
        });
      },
    );
  });
}
