import 'package:fave/shared/constants/symbols.dart' show kInterPunctCharater;
import 'package:intl/intl.dart' show DateFormat;

extension DateTimeFormatting on DateTime {
  String format(String pattern) {
    return DateFormat(pattern).format(this);
  }

  String get formattedDay {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(year, month, day);

    if (targetDate == today) {
      return "Today";
    } else if (targetDate == yesterday) {
      return "Yesterday";
    } else if (targetDate == tomorrow) {
      return "Tomorrow";
    }

    final int daysToMonday = today.weekday - 1;
    final DateTime startOfWeek = today.subtract(Duration(days: daysToMonday));
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    if (targetDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        targetDate.isBefore(endOfWeek.add(const Duration(seconds: 1)))) {
      return format('EEE');
    }

    return DateFormat('d $kInterPunctCharater MM').format(this);
  }

  String get pulseFormattedTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (!difference.isNegative) {
      if (difference.inSeconds < 60) {
        return "Just now";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes} min";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hr";
      }
    }

    return formattedDay;
  }
}
