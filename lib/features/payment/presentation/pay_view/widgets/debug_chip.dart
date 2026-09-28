import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class DebugChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const DebugChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Material(
      color: colors.chipFill,
      shape: StadiumBorder(
        side: BorderSide(color: colors.chipBorder, width: 1),
      ),
      child: InkWell(
        customBorder: StadiumBorder(
          side: BorderSide(color: colors.chipBorder, width: 1),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 6,
            bottom: 6,
            left: 12,
            right: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: text.chipLabel.copyWith(color: colors.primaryText),
              ),
              const SizedBox(width: 6),
              Text(
                '▾',
                style: text.chipLabel.copyWith(color: colors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
