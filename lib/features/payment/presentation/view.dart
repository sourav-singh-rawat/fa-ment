import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:auto_route/auto_route.dart' show AutoRouter;
import 'package:fave/features/payment/application/payment_flow_coordinator/payment_flow_coordinator.dart'
    show PaymentFlowCoordinator;
import 'package:fave/features/payment/domain/payment_gateway.dart';
import 'package:fave/features/payment/domain/payment_repository.dart';
import 'package:fave/shared/modules/id_generator/id_generator.dart';
import 'package:fave/shared/modules/task_scheduler/task_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show RepositoryProvider;

@RoutePage()
class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => PaymentFlowCoordinator(
        keyGenerator: IdGenerator.uuid(),
        repository: PaymentRepository.local(),
        gateway: PaymentGateway(),
        scheduler: TaskScheduler(),
      ),
      dispose: (repo) => repo.dispose(),
      child: AutoRouter(),
    );
  }
}
