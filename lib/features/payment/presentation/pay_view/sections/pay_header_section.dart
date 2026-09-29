import 'package:equatable/equatable.dart' show Equatable;
import 'package:fave/features/payment/constant/gateway_modes.dart';
import 'package:fave/features/payment/domain/entities/gateway_mode.dart'
    show GatewayModeType;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/presentation/pay_view/controller/pay_cubit.dart'
    show PayCubit, PayState;
import 'package:fave/features/payment/presentation/pay_view/widgets/backend_mode_sheet.dart'
    show BackendBehaviourSheet;
import 'package:fave/features/payment/presentation/pay_view/widgets/top_bar.dart'
    show PayTopBar;
import 'package:fave/shared/constants/symbols.dart' show kInterPunctCharater;
import 'package:fave/shared/utils/async_state.dart' show AsyncLoading;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocSelector, ReadContext;

class PayHeaderSection extends StatelessWidget {
  const PayHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PayCubit, PayState, _Data>(
      selector: (s) => _Data(
        mode: s.backendMode,
        isSending: s.createPaymentState is AsyncLoading<Payment>,
      ),
      builder: (context, data) {
        final modeDetails = SeededGatewayModes.byType(data.mode);
        return PayTopBar(
          backendModeLabel: 'Backend $kInterPunctCharater ${modeDetails.title}',
          onDebugTap: data.isSending
              ? null
              : () => _showBackendSheet(context, data.mode),
        );
      },
    );
  }

  Future<void> _showBackendSheet(
    BuildContext context,
    GatewayModeType selected,
  ) async {
    final cubit = context.read<PayCubit>();

    final result = await BackendBehaviourSheet.show(
      context,
      selected: selected,
    );

    if (result != null && !cubit.isClosed) {
      cubit.onChangeBackendMode(result);
    }
  }
}

class _Data extends Equatable {
  final GatewayModeType mode;
  final bool isSending;
  const _Data({required this.mode, required this.isSending});

  @override
  List<Object?> get props => [mode, isSending];
}
