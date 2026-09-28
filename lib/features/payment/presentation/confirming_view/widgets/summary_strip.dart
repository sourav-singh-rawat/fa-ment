import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/widgets/selection_label.dart' show FSectionLabel;
import 'package:flutter/material.dart';

class SummaryStrip extends StatelessWidget {
  final String amountAndRecipientSummary;

  const SummaryStrip({super.key, required this.amountAndRecipientSummary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FSectionLabel('PAYING'),
        const SizedBox(height: 4),
        Text(
          amountAndRecipientSummary,
          style: context.text.recentPayee.copyWith(
            fontSize: 14,
            height: 18 / 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
