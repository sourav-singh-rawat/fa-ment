library pay_view;

import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:auto_route/auto_route.dart' show AutoRouterX;
import 'package:fave/features/payment/application/payment_flow_coordinator/payment_flow_coordinator.dart'
    show PaymentFlowCoordinator;
import 'package:fave/features/payment/constant/gateway_modes.dart'
    show SeededGatewayModes;
import 'package:fave/features/payment/domain/entities/gateway_mode.dart';
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:fave/features/payment/presentation/pay_view/controller/pay_cubit.dart'
    show PayCubit, PayState;
import 'package:fave/shared/modules/router/i.router.gr.dart'
    show PaymentConfirmingRoute;
import 'package:fave/shared/utils/async_state.dart'
    show
        AsyncState,
        AsyncLoading,
        AsyncSuccess,
        AsyncFailure,
        AsyncIdle,
        AsyncPartial;
import 'package:fave/shared/utils/async_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocProvider, ReadContext, BlocListener, BlocSelector, BlocBuilder;

part 'widgets/recent_transaction.dart';

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
      child: _SideEffects(
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  BlocSelector<PayCubit, PayState, GatewayMode>(
                    selector: (state) => state.backendMode,
                    builder: (context, backendMode) {
                      return DropdownButton<GatewayMode>(
                        value: backendMode,
                        items: SeededGatewayModes.all
                            .map<DropdownMenuItem<GatewayMode>>((mode) {
                              return DropdownMenuItem<GatewayMode>(
                                value: mode,
                                child: Text(mode.title),
                              );
                            })
                            .toList(),
                        onChanged: (mode) {
                          if (mode == null) return;
                          context.read<PayCubit>().onChangeBackendMode(mode);
                        },
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  TextField(
                    onChanged: (value) {
                      context.read<PayCubit>().onChangeAmount(value);
                    },
                    decoration: InputDecoration(hintText: 'Enter amount'),
                  ),
                  _RecentTransactionList(),
                  BlocBuilder<PayCubit, PayState>(
                    //TODO: buildWhen
                    builder: (context, state) {
                      final isDisabled =
                          state.createPaymentState == AsyncLoading<Payment>() ||
                          state.amount.value.isEmpty;
                      return ElevatedButton(
                        onPressed: isDisabled
                            ? null
                            : () {
                                context.read<PayCubit>().onPressPay();
                              },
                        child: Text("Pay now"),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SideEffects extends StatelessWidget {
  final Widget child;

  const _SideEffects({super.key, required this.child});

  void navigateToConfirmView(BuildContext context, Payment payment) {
    context.navigateTo(PaymentConfirmingRoute(paymentAttempt: payment));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PayCubit, PayState>(
      listener: (context, state) {
        final status = state.createPaymentState;
        switch (status) {
          // case AsyncLoading():
          //   ScaffoldMessenger.of(context)
          //       .showSnackBar(SnackBar(content: Text('Loading')));
          //   break;
          case AsyncFailure():
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(status.error ?? 'Error!!!!!!')),
            );
            break;
          case AsyncPartial<Payment>():
            return navigateToConfirmView(context, status.data!);
          case AsyncSuccess<Payment>():
            return navigateToConfirmView(context, status.data!);
          default:
            return;
        }
      },
      child: child,
    );
  }
}
