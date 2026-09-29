import 'dart:async';

import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:auto_route/auto_route.dart' show AutoRouterX;
import 'package:fave/features/payment/application/payment_flow_coordinator/payment_flow_coordinator.dart'
    show PaymentFlowCoordinator;
import 'package:fave/features/payment/constant/recipients.dart';
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/presentation/confirming_view/controller/payment_confirm_cubit.dart'
    show PaymentConfirmCubit, PaymentConfirmState, PaymentFinalStatus;
import 'package:fave/features/payment/presentation/confirming_view/widgets/countdown_ring.dart'
    show CountdownRing;
import 'package:fave/features/payment/presentation/confirming_view/widgets/summary_strip.dart'
    show SummaryStrip;
import 'package:fave/shared/modules/router/i.router.gr.dart'
    show PaymentStatusRoute;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/utils/extensions/num_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocProvider, BlocListener, ReadContext;

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
      child: const _SideEffects(child: _Layout()),
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
  static late Completer<BuildContext> _progressCompleter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _progressCompleter = Completer();
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
      listenWhen: (previous, current) {
        return current is PaymentFinalStatus && previous is! PaymentFinalStatus;
      },
      listener: (context, state) async {
        if (state case PaymentFinalStatus(:final payment)) {
          context = await _progressCompleter.future;
          if (!context.mounted) return;
          context.router.replace(PaymentStatusRoute(payment: payment));
        }
      },
      child: widget.child,
    );
  }
}

class _Layout extends StatelessWidget {
  const _Layout({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final colors = context.colors;
    final text = context.text;

    return Scaffold(
      backgroundColor: colors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: layout.screenPadding,
          child: Column(
            children: [
              SummaryStrip(
                amountAndRecipientSummary: context
                    .read<PaymentConfirmCubit>()
                    .paymentAttempt
                    .summary,
              ),
              const Spacer(),
              const _ConfirmingStatus(),
              const Spacer(),
              Text(
                "Don't pay again — we'll confirm one way or the other.",
                style: text.recentStatus,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Payment {
  String get summary {
    final recipient = SeededRecipients.byId(recipientId);
    return '${amount.formatIndianRupees} to ${recipient.name}';
  }
}

class _ConfirmingStatus extends StatelessWidget {
  const _ConfirmingStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Column(
      spacing: 22,
      children: [
        const CountdownRing(),
        Text('Checking with your bank', style: text.confirmingHeading),
        Text(
          "This usually takes a few seconds.\nDon't close the app.",
          style: text.recentPayee.copyWith(
            fontSize: 13,
            height: 19 / 13,
            fontWeight: FontWeight.w400,
            color: colors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

mixin PaymentConfirmNavigatorMixin {
  void withdrawNavigationGuard(BuildContext context) {
    final completer = _SideEffectsState._progressCompleter;
    if (completer.isCompleted) return;
    completer.complete(context);
  }
}
