import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:flutter/material.dart';

@RoutePage()
class PaymentStatusView extends StatelessWidget {
  final Payment payment;
  const PaymentStatusView({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
