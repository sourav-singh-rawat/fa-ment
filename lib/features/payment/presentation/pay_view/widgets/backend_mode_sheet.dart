import 'package:auto_route/auto_route.dart';
import 'package:fave/features/payment/constant/gateway_modes.dart'
    show SeededGatewayModes;
import 'package:fave/features/payment/domain/entities/gateway_mode.dart'
    show GatewayMode, GatewayModeType;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/widgets/bottom_sheet.dart' show FBottomSheet;
import 'package:flutter/material.dart';

typedef VoidSelectedCallback = void Function(
  BuildContext context,
  GatewayModeType value,
);

class BackendBehaviourSheet extends StatelessWidget {
  final GatewayModeType selected;
  final VoidSelectedCallback? onSelected;

  const BackendBehaviourSheet._({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static Future<GatewayModeType?> show(
    BuildContext context, {
    required GatewayModeType selected,
    VoidSelectedCallback? onSelected,
  }) {
    return FBottomSheet.show(
      context,
      builder: (context) =>
          BackendBehaviourSheet._(selected: selected, onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final layout = context.layout;
    final text = context.text;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: layout.sheetGrabberSize.width,
            height: layout.sheetGrabberSize.height,
            decoration: BoxDecoration(
              color: colors.sheetGrabber,
              borderRadius: BorderRadius.circular(layout.sheetGrabberRadius),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Backend behaviour',
          style: text.confirmingHeading.copyWith(
            fontSize: 17,
            height: 22 / 17,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pick before you tap Pay. Applies to the next attempt only. To '
          'produce B5, background the app during Confirming in any mode.',
          style: text.recentStatus.copyWith(fontSize: 12.5, height: 17 / 12.5),
        ),
        const SizedBox(height: 8),
        for (final mode in SeededGatewayModes.all)
          _ModeRow(
            mode: mode,
            isSelected: mode.type == selected,
            onTap: () {
              onSelected?.call(context, mode.type);
              if (onSelected == null) {
                context.pop(mode.type);
              }
            },
          ),
      ],
    );
  }
}

class _ModeRow extends StatelessWidget {
  final GatewayMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeRow({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RadioDot(isSelected: isSelected, color: colors.link),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mode.title,
                    style: text.recipientName.copyWith(
                      fontSize: 14,
                      height: 19 / 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(mode.description, style: text.recentStatus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool isSelected;
  final Color color;
  const _RadioDot({required this.isSelected, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color : Colors.transparent,
        border: isSelected
            ? null
            : Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: SizedBox.square(
        dimension: 20,
        child: isSelected
            ? Center(
                child: CircleAvatar(radius: 4, backgroundColor: Colors.white),
              )
            : null,
      ),
    );
  }
}
