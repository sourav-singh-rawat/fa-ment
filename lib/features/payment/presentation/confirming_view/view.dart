import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:flutter/material.dart';

@RoutePage()
class PaymentConfirmingView extends StatelessWidget {
  final Payment paymentAttempt;
  const PaymentConfirmingView({super.key, required this.paymentAttempt});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
