part of 'pay_cubit.dart';

class PayState extends Equatable {
  final String? key;
  final GatewayMode backendMode;
  final Recipient recipient;
  final Valid<String> amount;
  final String? note;
  final Status<Payment> createPaymentStatus;
  const PayState({
    this.key,
    required this.backendMode,
    required this.recipient,
    required this.amount,
    this.note,
    required this.createPaymentStatus,
  });

  PayState.init()
    : this(
        backendMode: SeededGatewayModes.defaultMode,
        recipient: SeededRecipients.defaultRecipient,
        amount: Valid.init(''),
        createPaymentStatus: Status.idle(),
      );

  PayState copyWith({
    String? key,
    GatewayMode? backendMode,
    Recipient? recipient,
    Valid<String>? amount,
    String? note,
    Status<Payment>? createPaymentStatus,
  }) {
    return PayState(
      key: key,
      backendMode: backendMode ?? this.backendMode,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createPaymentStatus: createPaymentStatus ?? this.createPaymentStatus,
    );
  }

  @override
  List<Object> get props => [
    backendMode,
    recipient,
    amount,
    createPaymentStatus,
  ];
}
