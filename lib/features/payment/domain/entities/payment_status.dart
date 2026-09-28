sealed class PaymentStatus {
  final DateTime updatedAt;

  PaymentStatus({DateTime? updatedAt})
    : updatedAt = updatedAt ?? DateTime.now();

  bool get isTerminal => false;
}

final class PaymentSuccess extends PaymentStatus {
  PaymentSuccess({super.updatedAt});

  @override
  bool get isTerminal => true;

  @override
  String toString() => "Success";
}

final class PaymentFailed extends PaymentStatus {
  PaymentFailed({super.updatedAt});

  @override
  bool get isTerminal => true;

  @override
  String toString() => "Failed";
}

class PaymentPending extends PaymentStatus {
  PaymentPending({super.updatedAt});

  @override
  String toString() => "Pending";
}

class PaymentUnresolved extends PaymentStatus {
  PaymentUnresolved({super.updatedAt});

  @override
  String toString() => "Unresolved";
}
