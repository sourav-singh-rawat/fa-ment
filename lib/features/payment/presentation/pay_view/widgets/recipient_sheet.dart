import 'package:auto_route/auto_route.dart';
import 'package:fave/features/payment/constant/recipients.dart';
import 'package:fave/features/payment/domain/entities/recipient.dart';
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/widgets/avatar_circle.dart';
import 'package:fave/shared/widgets/bottom_sheet.dart' show FBottomSheet;
import 'package:flutter/material.dart';

typedef RecipientSelectedVoidCallback = void Function(
  BuildContext context,
  String id,
);

class RecipientSheet extends StatelessWidget {
  final String selectedRecipientId;
  final RecipientSelectedVoidCallback? onSelected;

  const RecipientSheet({
    super.key,
    required this.selectedRecipientId,
    this.onSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String selectedRecipientId,
    RecipientSelectedVoidCallback? onSelected,
  }) {
    return FBottomSheet.show(
      context,
      builder: (context) => RecipientSheet(
        selectedRecipientId: selectedRecipientId,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final layout = context.layout;
    final text = context.text;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.sheetGrabber,
              borderRadius: BorderRadius.circular(layout.sheetGrabberRadius),
            ),
            child: SizedBox(
              width: layout.sheetGrabberSize.width,
              height: layout.sheetGrabberSize.height,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Who are you paying?',
          style: text.confirmingHeading.copyWith(
            fontSize: 17,
            height: 22 / 17,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Five people are seeded. No search, no adding — pick one.',
          style: text.recentStatus.copyWith(fontSize: 12.5, height: 17 / 12.5),
        ),
        const SizedBox(height: 8),
        for (final recipient in SeededRecipients.all)
          _RecipientRow(
            recipient: recipient,
            isSelected: recipient.id == selectedRecipientId,
            onTap: () {
              onSelected?.call(context, recipient.id);
              if (onSelected == null) {
                context.pop(recipient.id);
              }
            },
          ),
      ],
    );
  }
}

class _RecipientRow extends StatelessWidget {
  final Recipient recipient;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecipientRow({
    required this.recipient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            const FCircleAvatar(size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipient.name,
                    style: text.recipientName.copyWith(
                      fontSize: 14,
                      height: 18 / 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    recipient.handle,
                    style: text.recentStatus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Text(
                '✓',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.link,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
