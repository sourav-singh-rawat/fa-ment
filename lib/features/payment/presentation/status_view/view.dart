import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:auto_route/auto_route.dart' show AutoRouterX;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/shared/modules/router/i.router.gr.dart' show PaymentRoute;
import 'package:flutter/material.dart';

@RoutePage()
class PaymentStatusView extends StatelessWidget {
  final Payment payment;
  const PaymentStatusView({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.router.popAndPush(PaymentRoute());
          },
          child: Text(payment.status.toString()),
        ),
      ),
    );
  }
}
