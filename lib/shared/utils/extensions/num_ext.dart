import 'package:flutter/material.dart' show SizedBox;

extension SizedBoxIntX on num {
  SizedBox get toHorizontalSizedBox => SizedBox(width: toDouble());

  SizedBox get toVerticalSizedBox => SizedBox(height: toDouble());
}
