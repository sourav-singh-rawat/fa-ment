import 'package:fave/shared/constants/symbols.dart' show kInterPunctCharater;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class ReferenceLine extends StatelessWidget {
  final String formattedTimestamp;
  final String reference;

  const ReferenceLine({
    super.key,
    required this.formattedTimestamp,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$formattedTimestamp $kInterPunctCharater UPI ref $reference',
      style: context.text.recentStatus.copyWith(
        fontSize: 12.5,
        height: 17 / 12.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
