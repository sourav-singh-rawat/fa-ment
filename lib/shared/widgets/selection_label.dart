import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class FSectionLabel extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  const FSectionLabel(this.text, {super.key, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: context.text.sectionLabel.merge(textStyle),
    );
  }
}
