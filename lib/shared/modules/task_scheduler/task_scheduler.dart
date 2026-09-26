import 'dart:async' show Timer;

abstract interface class TaskScheduler {
  factory TaskScheduler() => _TaskSchedulerImpl();

  void scheduleOnce(String taskId, Duration duration, void Function() callback);

  void schedulePeriodic(
    String taskId,
    Duration interval,
    void Function() callback,
  );

  void cancel(String taskId);

  void cancelAll();
}

class _TaskSchedulerImpl implements TaskScheduler {
  final Map<String, Timer> _timers = {};

  @override
  void scheduleOnce(
    String taskId,
    Duration duration,
    void Function() callback,
  ) {
    _timers[taskId]?.cancel();
    _timers[taskId] = Timer(duration, () {
      _timers.remove(taskId);
      callback();
    });
  }

  @override
  void schedulePeriodic(
    String taskId,
    Duration interval,
    void Function() callback,
  ) {
    _timers[taskId]?.cancel();
    _timers[taskId] = Timer.periodic(interval, (_) => callback());
  }

  @override
  void cancel(String taskId) {
    _timers.remove(taskId)?.cancel();
  }

  @override
  void cancelAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
