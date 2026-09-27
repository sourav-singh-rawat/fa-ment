import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:auto_route/auto_route.dart' show AutoRouterX;
import 'package:fave/features/payment/application/payment_flow_coordinator/payment_flow_coordinator.dart'
    show PaymentFlowCoordinator;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/presentation/pay_view/controller/pay_cubit.dart'
    show PayCubit, PayState;
import 'package:fave/shared/modules/router/i.router.gr.dart'
    show PaymentConfirmingRoute;
import 'package:fave/shared/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocProvider, ReadContext, BlocListener;

@RoutePage()
class PayView extends StatelessWidget {
  const PayView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PayCubit(context.read<PaymentFlowCoordinator>()),
      child: BlocListener<PayCubit, PayState>(
        listener: (context, state) {
          final status = state.createPaymentStatus;
          switch (status) {
            case Loading():
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Loading')));
            case Failure():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(status.error ?? 'Error!!!!!!')),
              );
            case Success<Payment>():
              context.navigateTo(
                PaymentConfirmingRoute(paymentAttempt: status.data!),
              );
            default:
              return;
          }
        },
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: (value) {
                  context.read<PayCubit>().onChangeAmount(value);
                },
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<PayCubit>().onPressPay();
                },
                child: Text("Pay now"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
