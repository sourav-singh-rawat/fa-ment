part of 'pay_cubit.dart';

class PayState extends Equatable {
  final String? key;
  final GatewayMode backendMode;
  final Recipient recipient;
  final ValidState<String> amount;
  final String? note;
  final AsyncState<List<Payment>> transactions;
  final AsyncState<Payment> createPaymentState;
  const PayState({
    this.key,
    required this.backendMode,
    required this.recipient,
    required this.amount,
    this.note,
    required this.transactions,
    required this.createPaymentState,
  });

  PayState.init()
    : this(
        backendMode: SeededGatewayModes.defaultMode,
        recipient: SeededRecipients.defaultRecipient,
        amount: ValidState.init(''),
        transactions: AsyncState.loading(),
        createPaymentState: AsyncState.idle(),
      );

  PayState copyWith({
    String? key,
    GatewayMode? backendMode,
    Recipient? recipient,
    ValidState<String>? amount,
    String? note,
    AsyncState<List<Payment>>? transactions,
    AsyncState<Payment>? createPaymentState,
  }) {
    return PayState(
      key: key,
      backendMode: backendMode ?? this.backendMode,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      transactions: transactions ?? this.transactions,
      createPaymentState: createPaymentState ?? this.createPaymentState,
    );
  }

  @override
  List<Object> get props => [
    backendMode,
    recipient,
    amount,
    transactions,
    createPaymentState,
  ];
}
