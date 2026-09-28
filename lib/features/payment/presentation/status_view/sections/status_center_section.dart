import 'package:fave/features/payment/constant/recipients.dart';
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/entities/payment_status.dart';
import 'package:fave/features/payment/presentation/status_view/widgets/notice_box.dart'
    show NoticeBox;
import 'package:fave/features/payment/presentation/status_view/widgets/quoted_note.dart'
    show QuotedNote;
import 'package:fave/features/payment/presentation/status_view/widgets/reason_line.dart'
    show ReasonLine;
import 'package:fave/features/payment/presentation/status_view/widgets/reference_line.dart'
    show ReferenceLine;
import 'package:fave/features/payment/presentation/status_view/widgets/status_badge.dart'
    show StatusBadge, BadgeKind;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/utils/extensions/datetime_ext.dart';
import 'package:fave/shared/utils/extensions/int_ext.dart';
import 'package:flutter/material.dart';

class StatusCenterSection extends StatelessWidget {
  final Payment payment;

  const StatusCenterSection({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return switch (payment.status) {
      PaymentSuccess() => _Success(payment: payment),
      PaymentFailed() => _Failed(payment: payment),
      _ => _Pending(payment: payment),
    };
  }
}

class _Success extends StatelessWidget {
  final Payment payment;
  const _Success({required this.payment});

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const StatusBadge(kind: BadgeKind.success),
        const SizedBox(height: 20),
        Text(
          '₹${payment.amount.formatIndianRupees} sent',
          style: text.successHeading,
          maxLines: 1,
          overflow: TextOverflow.clip,
        ),
        const SizedBox(height: 20),
        Text(
          payment.recipientSummary,
          style: text.recentPayee.copyWith(
            fontSize: 14,
            height: 19 / 14,
            fontWeight: FontWeight.w400,
            color: colors.secondaryText,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (payment.note case final note? when note.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          QuotedNote(note: note),
        ],
        const SizedBox(height: 20),
        ReferenceLine(
          formattedTimestamp: payment.status.updatedAt.format('EEE, h:mm a'),
          reference: payment.serverId ?? payment.id,
        ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  final Payment payment;
  const _Failed({required this.payment});

  @override
  Widget build(BuildContext context) {
    final text = context.text;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const StatusBadge(kind: BadgeKind.failed),
        const SizedBox(height: 20),
        Text(
          "Payment didn't go through",
          style: text.statusHeading,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Your money hasn't left your account.",
          style: text.recipientName.copyWith(fontSize: 14, height: 19 / 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const ReasonLine(reason: 'Your bank declined the request.'),
      ],
    );
  }
}

class _Pending extends StatelessWidget {
  final Payment payment;
  const _Pending({required this.payment});

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const StatusBadge(kind: BadgeKind.waiting),
        const SizedBox(height: 20),
        Text('Still confirming', style: text.statusHeading),
        const SizedBox(height: 8),
        Text(
          "Your bank hasn't confirmed yet. We'll keep checking and "
          'tell you the moment it does.',
          style: text.recentPayee.copyWith(
            fontSize: 13,
            height: 18 / 13,
            fontWeight: FontWeight.w400,
            color: colors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const NoticeBox(),
      ],
    );
  }
}

extension on Payment {
  String get recipientSummary {
    final recipient = SeededRecipients.byId(recipientId);

    return 'to ${recipient.name} · ${recipient.handle}';
  }
}
