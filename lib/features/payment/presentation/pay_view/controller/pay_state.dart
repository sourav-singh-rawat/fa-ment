part of 'pay_cubit.dart';

class PayState extends Equatable {
  final String? key;
  final GatewayMode backendMode;
  final Recipient recipient;
  final Valid<String> amount;
  final String? note;
  final CreatePaymentStatus status;
  const PayState({
    this.key,
    required this.backendMode,
    required this.recipient,
    required this.amount,
    this.note,
    required this.status,
  });

  PayState.init()
    : this(
        backendMode: SeededGatewayModes.defaultMode,
        recipient: SeededRecipients.defaultRecipient,
        amount: Valid.init(''),
        status: CreatePaymentStatus.idle,
      );

  PayState copyWith({
    String? key,
    GatewayMode? backendMode,
    Recipient? recipient,
    Valid<String>? amount,
    String? note,
    CreatePaymentStatus? status,
  }) {
    return PayState(
      key: key,
      backendMode: backendMode ?? this.backendMode,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [backendMode, recipient, amount, status];
}

enum CreatePaymentStatus { idle, sending }
