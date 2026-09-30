library pay_view;

import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:auto_route/auto_route.dart' show AutoRouterX;
import 'package:fave/features/payment/application/payment_flow_coordinator/payment_flow_coordinator.dart'
    show PaymentFlowCoordinator;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:fave/features/payment/presentation/pay_view/controller/pay_cubit.dart'
    show PayCubit, PayState;
import 'package:fave/features/payment/presentation/pay_view/sections/pay_action_section.dart'
    show PayActionSection;
import 'package:fave/features/payment/presentation/pay_view/sections/pay_form_section.dart'
    show PayFormSection;
import 'package:fave/features/payment/presentation/pay_view/sections/pay_header_section.dart'
    show PayHeaderSection;
import 'package:fave/features/payment/presentation/pay_view/sections/recent_payments_section.dart'
    show RecentPaymentsSection;
import 'package:fave/shared/modules/router/i.router.gr.dart'
    show PaymentConfirmingRoute;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/utils/async_state.dart'
    show AsyncSuccess, AsyncFailure, AsyncPartial;
import 'package:fave/shared/utils/async_state.dart';
import 'package:fave/shared/widgets/view_wapper.dart' show FView;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocProvider, ReadContext, BlocListener;

@RoutePage()
class PayView extends StatelessWidget {
  const PayView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PayCubit(
        paymentFlowCoordinator: context.read<PaymentFlowCoordinator>(),
        paymentRepository: context.read<PaymentRepository>(),
      )..fetchRecentTransactions(),
      child: const _SideEffects(child: _PayLayout()),
    );
  }
}

class _PayLayout extends StatelessWidget {
  const _PayLayout();

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    return FView(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PayHeaderSection(),
          SizedBox(height: layout.payBlockGap),
          const PayFormSection(),
          SizedBox(height: layout.payBlockGap),
          const RecentPaymentsSection(),
          const Spacer(),
          const PayActionSection(),
        ],
      ),
    );
  }
}

class _SideEffects extends StatelessWidget {
  final Widget child;

  const _SideEffects({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PayCubit, PayState>(
      listenWhen: (previous, current) {
        final previousPaymentState = previous.createPaymentState;
        final currentPaymentState = current.createPaymentState;

        final currentHasPayment =
            currentPaymentState is AsyncPartial<Payment> ||
            currentPaymentState is AsyncSuccess<Payment>;
        final previousHadPayment =
            previousPaymentState is AsyncPartial<Payment> ||
            previousPaymentState is AsyncSuccess<Payment>;

        final currentFailed = currentPaymentState is AsyncFailure;
        final previousFailed = previousPaymentState is AsyncFailure;

        return (currentHasPayment && !previousHadPayment) ||
            (currentFailed && !previousFailed);
      },
      listener: (context, state) {
        final paymentState = state.createPaymentState;

        switch (paymentState) {
          case AsyncPartial<Payment>(:final data) when data != null:
          case AsyncSuccess<Payment>(:final data) when data != null:
            context.router.replace(
              PaymentConfirmingRoute(paymentAttempt: data),
            );
          case AsyncFailure(:final error):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error ?? 'Unable to start payment')),
            );
          default:
            break;
        }
      },
      child: child,
    );
  }
}

// class _SideEffects extends StatelessWidget {
//   final Widget child;
//
//   const _SideEffects({super.key, required this.child});
//
//   void navigateToConfirmView(BuildContext context, Payment payment) {
//     context.navigateTo(PaymentConfirmingRoute(paymentAttempt: payment));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<PayCubit, PayState>(
//       listener: (context, state) {
//         final status = state.createPaymentState;
//         switch (status) {
//           // case AsyncLoading():
//           //   ScaffoldMessenger.of(context)
//           //       .showSnackBar(SnackBar(content: Text('Loading')));
//           //   break;
//           case AsyncFailure():
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(status.error ?? 'Error!!!!!!')),
//             );
//             break;
//           case AsyncPartial<Payment>():
//             return navigateToConfirmView(context, status.data!);
//           case AsyncSuccess<Payment>():
//             return navigateToConfirmView(context, status.data!);
//           default:
//             return;
//         }
//       },
//       child: child,
//     );
//   }
// }
