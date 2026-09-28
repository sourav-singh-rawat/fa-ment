import 'package:fave/features/payment/presentation/widgets/inline_status_badge.dart'
    show InlineBadgeKind, InlineStatusBadge;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class RecentPaymentRow extends StatelessWidget {
  final String payeeName;
  final String statusLine;
  final String formattedAmount;
  final InlineBadgeKind? badge;
  final bool showTopDivider;

  const RecentPaymentRow({
    super.key,
    required this.payeeName,
    required this.statusLine,
    required this.formattedAmount,
    this.badge,
    this.showTopDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  payeeName,
                  style: text.recentPayee,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(statusLine, style: text.recentStatus),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      InlineStatusBadge(kind: badge!),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '₹$formattedAmount',
            style: text.recentAmount,
            maxLines: 1,
            overflow: TextOverflow.clip, // amount never truncates
          ),
        ],
      ),
    );

    if (showTopDivider) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.fieldUnderline)),
        ),
        child: child,
      );
    }

    return child;
  }
}

class RecentPaymentEmptyLabel extends StatelessWidget {
  const RecentPaymentEmptyLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'No payments yet',
      style: context.text.recentStatus.copyWith(fontSize: 13, height: 18 / 13),
    );
  }
}
