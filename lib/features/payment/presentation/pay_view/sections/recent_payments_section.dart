import 'package:fave/features/payment/constant/recipients.dart';
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/entities/payment_status.dart';
import 'package:fave/features/payment/presentation/pay_view/controller/pay_cubit.dart'
    show PayCubit, PayState;
import 'package:fave/features/payment/presentation/pay_view/widgets/recent_payment.dart'
    show RecentPaymentEmptyLabel, RecentPaymentRow;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/utils/async_state.dart'
    show AsyncState, AsyncSuccess, AsyncPartial;
import 'package:fave/shared/utils/extensions/int_ext.dart';
import 'package:fave/shared/widgets/selection_label.dart' show FSectionLabel;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocSelector;

class RecentPaymentsSection extends StatelessWidget {
  const RecentPaymentsSection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const FSectionLabel('RECENT'),
      SizedBox(height: context.layout.recentListFirstRowGap),
      BlocSelector<PayCubit, PayState, AsyncState<List<Payment>>>(
        selector: (s) => s.transactions,
        builder: (context, result) {
          final records = switch (result) {
            AsyncSuccess<List<Payment>>(:final data) => data,
            AsyncPartial<List<Payment>>(:final data) => data,
            _ => null,
          };

          // No indefinite spinner: the specification draws an empty label
          // and up to two history rows, not a loading variant here.
          if (records == null || records.isEmpty) {
            return const RecentPaymentEmptyLabel();
          }

          final recordsMap = records.asMap();

          return Column(
            children: recordsMap.entries.map<Widget>((entry) {
              final record = entry.value;
              final recipient = SeededRecipients.byId(record.id);

              final isFirstRecord = entry.key <= 0;
              return RecentPaymentRow(
                payeeName: recipient.name,
                statusLine: switch (record.status) {
                  PaymentPending() || PaymentUnresolved() => 'Sent',
                  _ => record.status.toString(),
                },
                formattedAmount: record.amount.formatIndianRupees,
                showTopDivider: !isFirstRecord,
              );
            }).toList(),
          );
        },
      ),
    ],
  );
}
