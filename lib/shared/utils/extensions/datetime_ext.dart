import 'package:intl/intl.dart' show DateFormat;

extension DateTimeFormatting on DateTime {
  String format(String pattern) {
    return DateFormat(pattern).format(this);
  }
}
