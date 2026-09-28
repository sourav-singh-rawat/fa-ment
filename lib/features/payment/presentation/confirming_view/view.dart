library payment_confirming_view;

import 'dart:async' show Timer;

import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:auto_route/auto_route.dart' show AutoRouterX;
import 'package:fave/features/payment/application/payment_flow_coordinator/payment_flow_coordinator.dart'
    show PaymentFlowCoordinator;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/presentation/confirming_view/controller/payment_confirm_cubit.dart'
    show
        PaymentConfirmCubit,
        PaymentConfirmState,
        PaymentFinalStatus,
        kConfirmingDeadlineDuration;
import 'package:fave/shared/modules/router/i.router.gr.dart'
    show PaymentStatusRoute;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocProvider, BlocListener, ReadContext;

part 'widgets/progress_indicator.dart';

@RoutePage()
class PaymentConfirmingView extends StatelessWidget {
  final Payment paymentAttempt;

  const PaymentConfirmingView({super.key, required this.paymentAttempt});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentConfirmCubit(
        paymentFlowCoordinator: context.read<PaymentFlowCoordinator>(),
        paymentAttempt: paymentAttempt,
      )..startConfirming(),
      child: const _SideEffects(
        child: Scaffold(body: Center(child: _ProgressIndicator())),
      ),
    );
  }
}

class _SideEffects extends StatefulWidget {
  final Widget child;

  const _SideEffects({super.key, required this.child});

  @override
  State<_SideEffects> createState() => _SideEffectsState();
}

class _SideEffectsState extends State<_SideEffects>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final paymentConfirmCubit = context.read<PaymentConfirmCubit>();
    if (state == AppLifecycleState.resumed) {
      paymentConfirmCubit.onAppResumed();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      paymentConfirmCubit.onAppBackgrounded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentConfirmCubit, PaymentConfirmState>(
      listener: (context, state) {
        switch (state) {
          case PaymentFinalStatus():
            context.navigateTo(PaymentStatusRoute(payment: state.payment));
          default:
            return;
        }
      },
      child: widget.child,
    );
  }
}
