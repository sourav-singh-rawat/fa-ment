import 'package:fave/shared/constants/symbols.dart' show kIndianRupee;
import 'package:flutter/material.dart' show SizedBox;
import 'package:intl/intl.dart' show NumberFormat;

extension NumX on num {
  String get formatIndianRupees {
    final formater = NumberFormat.currency(
      locale: 'en_IN',
      symbol: kIndianRupee,
      decimalDigits: 0,
    );

    return formater.format(this);
  }
}

extension SizedBoxIntX on num {
  SizedBox get toHorizontalSizedBox => SizedBox(width: toDouble());

  SizedBox get toVerticalSizedBox => SizedBox(height: toDouble());
}
