sealed class PaymentStatus {
  final DateTime updatedAt;

  PaymentStatus({DateTime? updatedAt})
    : updatedAt = updatedAt ?? DateTime.now();

  factory PaymentStatus.fromSqlJson(Map<String, dynamic> json) {
    final type = json['status'] as String;
    final updatedAt = DateTime.parse(json['updatedAt'] as String);

    return switch (type) {
      'PaymentSuccess' => PaymentSuccess(updatedAt: updatedAt),
      'PaymentFailed' => PaymentFailed(updatedAt: updatedAt),
      'PaymentSending' => PaymentSending(updatedAt: updatedAt),
      'PaymentConfirming' => PaymentConfirming(updatedAt: updatedAt),
      'PaymentUnresolved' || _ => PaymentUnresolved(updatedAt: updatedAt),
    };
  }

  Map<String, dynamic> toSqlJson() {
    return {
      'status': runtimeType.toString(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

final class PaymentSuccess extends PaymentStatus {
  PaymentSuccess({super.updatedAt});
}

final class PaymentFailed extends PaymentStatus {
  PaymentFailed({super.updatedAt});
}

sealed class PaymentPending extends PaymentStatus {
  PaymentPending({super.updatedAt});
}

final class PaymentSending extends PaymentPending {
  PaymentSending({super.updatedAt});
}

final class PaymentConfirming extends PaymentPending {
  PaymentConfirming({super.updatedAt});
}

//TODO: Check if required
// final class PaymentStillConfirming extends PaymentPending {
//   PaymentStillConfirming({super.updatedAt});
// }

final class PaymentUnresolved extends PaymentPending {
  PaymentUnresolved({super.updatedAt});
}
