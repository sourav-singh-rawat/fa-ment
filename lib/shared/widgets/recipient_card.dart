import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/widgets/avatar_circle.dart' show AvatarCircle;
import 'package:flutter/material.dart';

class RecipientCard extends StatelessWidget {
  final String name;
  final String handle;
  final VoidCallback onTap;

  const RecipientCard({
    super.key,
    required this.name,
    required this.handle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final layout = context.layout;
    final text = context.text;

    return Material(
      color: colors.recipientCard,
      borderRadius: BorderRadius.circular(layout.recipientCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(layout.recipientCardRadius),
        child: Padding(
          padding: layout.recipientCardPadding,
          child: Row(
            children: [
              AvatarCircle(size: layout.recipientAvatarSize),
              SizedBox(width: layout.recipientCardPadding.left - 4), // ~14 gap
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: text.recipientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      handle,
                      style: text.recentStatus.copyWith(
                        fontSize: 12.5,
                        height: 17 / 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
