import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:auto_route/auto_route.dart' show AutoRouterX;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/shared/modules/router/i.router.gr.dart'
    show PaymentStatusRoute;
import 'package:flutter/material.dart';

@RoutePage()
class PaymentConfirmingView extends StatelessWidget {
  final Payment paymentAttempt;
  const PaymentConfirmingView({super.key, required this.paymentAttempt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            context.navigateTo(PaymentStatusRoute(payment: paymentAttempt));
          },
          child: Text("Confirm"),
        ),
      ),
    );
  }
}
