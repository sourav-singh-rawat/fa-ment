import 'package:equatable/equatable.dart';
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show PaymentStatus, PaymentSending;

class Payment extends Equatable {
  final String id;
  final String? serverId;
  final String recipientId;
  final int amount;
  final String? note;
  final PaymentStatus status;
  final DateTime createdAt;

  const new({
    required this.id,
    this.serverId,
    required this.recipientId,
    required this.amount,
    this.note,
    required this.status,
    required this.createdAt,
  });

  factory create({
    required String key,
    required String recipientId,
    required int amount,
    required String? note,
  }) {
    return Payment(
      id: key,
      recipientId: recipientId,
      amount: amount,
      note: note,
      status: PaymentSending(),
      createdAt: DateTime.now(),
    );
  }

  Payment copyWith({String? serverId, PaymentStatus? status}) {
    return Payment(
      id: id,
      serverId: serverId ?? this.serverId,
      recipientId: recipientId,
      amount: amount,
      note: note,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  factory Payment.fromSqlJson(Map<String, dynamic> json) {
    return Payment(
      id: json[PaymentCharacters.id] as String,
      serverId: json[PaymentCharacters.serverId] as String?,
      recipientId: json[PaymentCharacters.recipientId] as String,
      amount: json[PaymentCharacters.amount] as int,
      note: json[PaymentCharacters.note] as String?,
      status: PaymentStatus.fromSqlJson({
        PaymentCharacters.status: json[PaymentCharacters.status] as String,
        PaymentCharacters.updatedAt:
            json[PaymentCharacters.updatedAt] as String,
      }),
      createdAt: DateTime.parse(json[PaymentCharacters.createdAt] as String),
    );
  }

  Map<String, dynamic> toSqlJson() {
    return {
      PaymentCharacters.id: id,
      PaymentCharacters.serverId: serverId,
      PaymentCharacters.recipientId: recipientId,
      PaymentCharacters.amount: amount,
      PaymentCharacters.note: note,
      PaymentCharacters.createdAt: createdAt.toIso8601String(),
      ...status.toSqlJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    serverId,
    recipientId,
    amount,
    note,
    status,
    createdAt,
  ];
}

class PaymentCharacters {
  const PaymentCharacters._();
  static const tableName = "Payments";
  static const id = "id";
  static const serverId = "serverId";
  static const recipientId = "recipientId";
  static const amount = "amount";
  static const note = "note";
  static const status = "status";
  static const updatedAt = "updatedAt";
  static const createdAt = "createdAt";
}
