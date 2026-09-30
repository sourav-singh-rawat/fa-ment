import 'package:equatable/equatable.dart';
import 'package:fave/features/payment/constant/recipients.dart';
import 'package:fave/features/payment/presentation/pay_view/controller/pay_cubit.dart'
    show PayCubit, PayState;
import 'package:fave/features/payment/presentation/pay_view/widgets/amount_field.dart'
    show
        AmountInput,
        AmountFieldState,
        AmountEmpty,
        AmountAboveLimit,
        AmountBelowMinimum,
        AmountValid;
import 'package:fave/features/payment/presentation/pay_view/widgets/note_field.dart'
    show NoteInput;
import 'package:fave/features/payment/presentation/pay_view/widgets/recipient_card.dart'
    show RecipientCard;
import 'package:fave/features/payment/presentation/pay_view/widgets/recipient_sheet.dart'
    show RecipientSheet;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/utils/async_state.dart' show AsyncLoading;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocSelector, ReadContext;

class PayFormSection extends StatelessWidget {
  const PayFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _RecipientSection(),
        SizedBox(height: context.layout.payBlockGap),
        const _AmountSection(),
        const SizedBox(height: 12),
        const _NoteSection(),
      ],
    );
  }
}

class _RecipientSection extends StatelessWidget {
  const _RecipientSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PayCubit, PayState, _RecipientData>(
      selector: (s) => _RecipientData(
        recipientId: s.recipientId,
        isSending: s.createPaymentState is AsyncLoading,
      ),
      builder: (context, data) {
        final recipient = SeededRecipients.byId(data.recipientId);

        return RecipientCard(
          name: recipient.name,
          handle: recipient.handle,
          onTap: data.isSending
              ? null
              : () => _showRecipientSheet(context, recipient.id),
        );
      },
    );
  }

  Future<void> _showRecipientSheet(
    BuildContext context,
    String selectedRecipientId,
  ) async {
    final cubit = context.read<PayCubit>();

    final result = await RecipientSheet.show(
      context,
      selectedRecipientId: selectedRecipientId,
    );

    if (result != null && !cubit.isClosed) {
      cubit.onChangeRecipient(result);
    }
  }
}

class _RecipientData extends Equatable {
  const _RecipientData({required this.recipientId, required this.isSending});
  final String recipientId;
  final bool isSending;

  @override
  List<Object?> get props => [recipientId, isSending];
}

class _AmountSection extends StatelessWidget {
  const _AmountSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PayCubit, PayState, AmountFieldData>(
      selector: (s) => AmountFieldData(
        fieldState: AmountFieldData.toAmountFieldState(s.amount),
        isSending: s.createPaymentState is AsyncLoading,
      ),
      builder: (context, data) => AmountInput(
        state: data.fieldState,
        enabled: !data.isSending,
        onChanged: context.read<PayCubit>().onChangeAmount,
      ),
    );
  }
}

class AmountFieldData {
  final AmountFieldState fieldState;
  final bool isSending;

  const AmountFieldData({required this.fieldState, required this.isSending});

  static AmountFieldState toAmountFieldState(int? amount) {
    if (amount == null) {
      return AmountEmpty();
    }

    if (amount < 1) {
      return AmountBelowMinimum(amount);
    }

    if (amount > 100000) {
      return AmountAboveLimit(amount);
    }

    return AmountValid(amount);
  }
}

class _NoteSection extends StatelessWidget {
  const _NoteSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PayCubit, PayState, _NoteData>(
      selector: (s) => _NoteData(
        note: s.note ?? '',
        isSending: s.createPaymentState is AsyncLoading,
      ),
      builder: (context, data) => NoteInput(
        value: data.note,
        enabled: !data.isSending,
        onChanged: context.read<PayCubit>().onChangeNote,
      ),
    );
  }
}

class _NoteData extends Equatable {
  const _NoteData({required this.note, required this.isSending});
  final String note;
  final bool isSending;

  @override
  List<Object?> get props => [note, isSending];
}
