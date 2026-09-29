import 'package:equatable/equatable.dart' show Equatable;
import 'package:fave/features/payment/presentation/pay_view/controller/pay_cubit.dart'
    show PayCubit, PayState;
import 'package:fave/features/payment/presentation/pay_view/sections/pay_form_section.dart'
    show AmountFieldData;
import 'package:fave/features/payment/presentation/pay_view/widgets/amount_field.dart';
import 'package:fave/shared/utils/async_state.dart' show AsyncLoading;
import 'package:fave/shared/widgets/buttons/cta_button.dart'
    show FCtaVariant, FCtaButton;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocSelector, ReadContext;

class PayActionSection extends StatelessWidget {
  const PayActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PayCubit, PayState, _Data>(
      selector: (s) {
        if (s.createPaymentState is AsyncLoading) {
          return const _Data('Paying…', FCtaVariant.loading);
        }

        final fieldState = AmountFieldData.toAmountFieldState(s.amount);
        final data = switch (fieldState) {
          AmountValid(:final formattedValue) => _Data(
            'Pay $formattedValue',
            FCtaVariant.enabled,
          ),
          _ => _Data('Pay', FCtaVariant.disabled),
        };

        return data;
      },
      builder: (context, data) => FCtaButton(
        label: data.label,
        variant: data.variant,
        onPressed: data.variant == FCtaVariant.enabled
            ? context.read<PayCubit>().onPressPay
            : null,
      ),
    );
  }
}

class _Data extends Equatable {
  const _Data(this.label, this.variant);
  final String label;
  final FCtaVariant variant;

  @override
  List<Object?> get props => [label, variant];
}
