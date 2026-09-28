import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class FCircleAvatar extends StatelessWidget {
  final double size;
  final Color? color;

  const FCircleAvatar({super.key, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color ?? colors.avatarAndWaitingRing,
    );
  }
}
