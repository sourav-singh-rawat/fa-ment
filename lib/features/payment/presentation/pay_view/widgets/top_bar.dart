import 'package:fave/features/payment/presentation/pay_view/widgets/debug_chip.dart'
    show DebugChip;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class PayTopBar extends StatelessWidget {
  final String backendModeLabel;
  final VoidCallback? onDebugTap;

  const PayTopBar({super.key, required this.backendModeLabel, this.onDebugTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          const SizedBox(width: 14),
          Text(
            'Pay',
            style: context.text.confirmingHeading.copyWith(
              fontSize: 17,
              height: 22 / 17,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          DebugChip(label: backendModeLabel, onTap: onDebugTap),
        ],
      ),
    );
  }
}
