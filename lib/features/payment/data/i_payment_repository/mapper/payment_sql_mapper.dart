part of '../i.local_payment_repository.dart';

class _PaymentSqlMapper {
  static Payment fromData(Map<String, dynamic> json) {
    return Payment(
      id: json[_PaymentCharacters.id] as String,
      serverId: json[_PaymentCharacters.serverId] as String?,
      recipientId: json[_PaymentCharacters.recipientId] as String,
      amount: json[_PaymentCharacters.amount] as int,
      note: json[_PaymentCharacters.note] as String?,
      status: _PaymentStatusSqlMapper.fromData(json),
      createdAt: DateTime.parse(json[_PaymentCharacters.createdAt] as String),
    );
  }

  static Map<String, dynamic> toData(Payment payment) {
    return {
      _PaymentCharacters.id: payment.id,
      _PaymentCharacters.serverId: payment.serverId,
      _PaymentCharacters.recipientId: payment.recipientId,
      _PaymentCharacters.amount: payment.amount,
      _PaymentCharacters.note: payment.note,
      _PaymentCharacters.createdAt: payment.createdAt.toIso8601String(),
      ..._PaymentStatusSqlMapper.toData(payment.status),
    };
  }
}
