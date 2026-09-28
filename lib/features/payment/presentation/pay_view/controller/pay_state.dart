part of 'pay_cubit.dart';

class PayState extends Equatable {
  final String? key;
  final GatewayModeType backendMode;
  final String recipientId;
  final int? amount;
  final String? note;
  final AsyncState<List<Payment>> transactions;
  final AsyncState<Payment> createPaymentState;
  const PayState({
    this.key,
    required this.backendMode,
    required this.recipientId,
    this.amount,
    this.note,
    required this.transactions,
    required this.createPaymentState,
  });

  PayState.init()
    : this(
        backendMode: SeededGatewayModes.defaultMode.type,
        recipientId: SeededRecipients.defaultRecipient.id,
        transactions: AsyncState.loading(),
        createPaymentState: AsyncState.idle(),
      );

  PayState copyWith({
    String? key,
    GatewayModeType? backendMode,
    String? recipientId,
    int? amount,
    String? note,
    AsyncState<List<Payment>>? transactions,
    AsyncState<Payment>? createPaymentState,
  }) {
    return PayState(
      key: key,
      backendMode: backendMode ?? this.backendMode,
      recipientId: recipientId ?? this.recipientId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      transactions: transactions ?? this.transactions,
      createPaymentState: createPaymentState ?? this.createPaymentState,
    );
  }

  @override
  List<Object> get props => [
    backendMode,
    recipientId,
    amount ?? 0,
    note ?? '',
    transactions,
    createPaymentState,
  ];
}
