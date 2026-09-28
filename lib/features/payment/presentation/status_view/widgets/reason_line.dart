import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class ReasonLine extends StatelessWidget {
  final String reason;
  const ReasonLine({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Text(
      reason,
      style: context.text.recentStatus.copyWith(
        fontSize: 12.5,
        height: 17 / 12.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
