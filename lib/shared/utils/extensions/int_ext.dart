extension IntX on int {
  String get formatIndianRupees {
    final digits = toString();
    if (digits.length <= 3) return digits;

    final lastThree = digits.substring(digits.length - 3);
    final rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];

    var end = rest.length;
    while (end > 2) {
      groups.insert(0, rest.substring(end - 2, end));
      end -= 2;
    }
    if (end > 0) groups.insert(0, rest.substring(0, end));

    return '${groups.join(',')},$lastThree';
  }
}
