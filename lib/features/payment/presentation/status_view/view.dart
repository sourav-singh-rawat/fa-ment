import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/presentation/status_view/sections/status_actions_section.dart'
    show StatusActionsSection;
import 'package:fave/features/payment/presentation/status_view/sections/status_center_section.dart'
    show StatusCenterSection;
import 'package:fave/shared/widgets/view_wapper.dart' show FView;
import 'package:flutter/material.dart';

@RoutePage()
class PaymentStatusView extends StatelessWidget {
  final Payment payment;
  const PaymentStatusView({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return FView(
      body: Column(
        children: [
          Expanded(
            child: Center(child: StatusCenterSection(payment: payment)),
          ),
          StatusActionsSection(payment: payment),
        ],
      ),
    );
  }
}
