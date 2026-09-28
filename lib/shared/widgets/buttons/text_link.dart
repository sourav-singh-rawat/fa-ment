import 'package:fave/shared/modules/theme/theme.dart'
    show FThemeContext, FFontsAwareLinkStyle;
import 'package:flutter/material.dart';

enum FLinkVariant { active, disabled }

class FTextLink extends StatelessWidget {
  final String label;
  final FLinkVariant variant;
  final VoidCallback? onTap;

  const FTextLink({
    super.key,
    required this.label,
    this.variant = FLinkVariant.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (variant == FLinkVariant.disabled) {
      return Text(
        label,
        style: context.text.checkingLink, // 14/Medium, secondary, no underline
      );
    }

    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: FFontsAwareLinkStyle.of(context).copyWith(
          color: colors.link,
          decoration: TextDecoration.underline,
          decorationColor: colors.link,
        ),
      ),
    );
  }
}
