import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class QuotedNote extends StatelessWidget {
  final String note;
  const QuotedNote({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Text(
      '"$note"',
      style: context.text.successNote,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
