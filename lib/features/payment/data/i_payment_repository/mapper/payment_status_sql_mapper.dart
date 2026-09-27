part of '../i.local_payment_repository.dart';

class _PaymentStatusSqlMapper {
  static PaymentStatus fromData(Map<String, dynamic> json) {
    final type = json[_PaymentCharacters.status] as String;
    final updatedAt = DateTime.parse(
      json[_PaymentCharacters.updatedAt] as String,
    );

    return switch (type) {
      'Success' => PaymentSuccess(updatedAt: updatedAt),
      'Failed' => PaymentFailed(updatedAt: updatedAt),
      'Checking' => PaymentPending(updatedAt: updatedAt),
      _ => PaymentUnresolved(updatedAt: updatedAt),
    };
  }

  static Map<String, dynamic> toData(PaymentStatus status) {
    return {
      _PaymentCharacters.status: status.toString(),
      _PaymentCharacters.updatedAt: status.updatedAt.toIso8601String(),
    };
  }
}
