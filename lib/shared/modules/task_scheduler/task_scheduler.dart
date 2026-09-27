import 'package:fave/shared/modules/task_scheduler/i.task_scheduler.dart'
    show TaskSchedulerImpl;

abstract interface class TaskScheduler {
  factory TaskScheduler() => TaskSchedulerImpl();

  void scheduleOnce(String taskId, Duration duration, void Function() callback);

  void schedulePeriodic(
    String taskId,
    Duration interval,
    void Function() callback,
  );

  void cancel(String taskId);

  void cancelAll();
}
