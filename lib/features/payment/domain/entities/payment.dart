import 'package:equatable/equatable.dart';
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show PaymentStatus, PaymentPending;

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
      status: PaymentPending(),
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
