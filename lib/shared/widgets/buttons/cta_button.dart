import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

enum FCtaVariant { enabled, disabled, loading }

class FCtaButton extends StatelessWidget {
  final String label;
  final FCtaVariant variant;
  final VoidCallback? onPressed;

  const FCtaButton({
    super.key,
    required this.label,
    required this.variant,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final layout = context.layout;
    final text = context.text;

    final Color background = switch (variant) {
      FCtaVariant.enabled => colors.primaryCta,
      FCtaVariant.disabled => colors.invalidCta,
      FCtaVariant.loading => colors.loadingCta,
    };

    final bool isTappable = variant == FCtaVariant.enabled;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: background,
        shape: StadiumBorder(
          side: BorderSide(
            color: background,
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        // borderRadius: BorderRadius.circular(layout.primaryCtaRadius),
        child: InkWell(
          onTap: isTappable ? onPressed : null,
          borderRadius: BorderRadius.circular(layout.primaryCtaRadius),
          child: Padding(
            padding: layout.primaryCtaPadding.add(
              const EdgeInsets.symmetric(horizontal: 22),
            ),
            child: Center(
              child: Text(
                label,
                style: text.ctaLabel,
                maxLines: 1,
                overflow: TextOverflow.clip, // amount text never truncates
              ),
            ),
          ),
        ),
      ),
    );
  }
}
