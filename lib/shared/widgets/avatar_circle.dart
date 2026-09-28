import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class FAvatarCircle extends StatelessWidget {
  final double size;
  final Color? overrideColor;

  const FAvatarCircle({super.key, required this.size, this.overrideColor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: overrideColor ?? colors.avatarAndWaitingRing,
        shape: BoxShape.circle,
      ),
    );
  }
}
