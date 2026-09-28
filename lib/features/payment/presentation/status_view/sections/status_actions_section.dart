import 'package:auto_route/auto_route.dart' show AutoRouterX;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/entities/payment_status.dart';
import 'package:fave/shared/modules/router/i.router.gr.dart' show PaymentRoute;
import 'package:fave/shared/widgets/buttons/cta_button.dart'
    show FCtaButton, FCtaVariant;
import 'package:fave/shared/widgets/buttons/text_link.dart' show FTextLink;
import 'package:flutter/material.dart';

class StatusActionsSection extends StatelessWidget {
  final Payment payment;

  const StatusActionsSection({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return switch (payment.status) {
      PaymentSuccess() => FCtaButton(
        label: 'Done',
        variant: FCtaVariant.enabled,
        onPressed: () => _returnToHome(context),
      ),
      PaymentFailed() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FCtaButton(
            label: 'Try again',
            variant: FCtaVariant.enabled,
            onPressed: () => _returnToHome(context),
          ),
          const SizedBox(height: 18),
          FTextLink(label: 'Go back', onTap: () => _returnToHome(context)),
        ],
      ),
      _ => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FCtaButton(
            label: 'Go to home',
            variant: FCtaVariant.enabled,
            onPressed: () => _returnToHome(context),
          ),
          const SizedBox(height: 18),
          FTextLink(
            label: 'Check status again',
            onTap: () => _returnToHome(context),
          ),
        ],
      ),
    };
  }

  void _returnToHome(BuildContext context) {
    context.router.popAndPush(PaymentRoute());
  }
}
