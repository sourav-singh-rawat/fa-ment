import 'package:fave/shared/modules/theme/theme.dart'
    show FThemeContext, FFontsAwareLinkStyle;
import 'package:flutter/material.dart';

enum FaveLinkVariant { active, disabled }

class FaveTextLink extends StatelessWidget {
  final String label;
  final FaveLinkVariant variant;
  final VoidCallback? onTap;

  const FaveTextLink({
    super.key,
    required this.label,
    this.variant = FaveLinkVariant.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (variant == FaveLinkVariant.disabled) {
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
