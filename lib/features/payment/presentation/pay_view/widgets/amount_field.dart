import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/widgets/selection_label.dart' show FSectionLabel;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;

sealed class AmountFieldState {
  const AmountFieldState();
}

final class AmountEmpty extends AmountFieldState {
  const AmountEmpty();
}

final class AmountValid extends AmountFieldState {
  final String formattedValue;
  const AmountValid(this.formattedValue);
}

final class AmountInvalid extends AmountFieldState {
  const AmountInvalid();
}

final class AmountBelowMinimum extends AmountFieldState {
  final String rawDisplayValue;
  const AmountBelowMinimum(this.rawDisplayValue);
}

final class AmountAboveLimit extends AmountFieldState {
  final String formattedValue;
  const AmountAboveLimit(this.formattedValue);
}

class AmountInput extends StatefulWidget {
  final AmountFieldState state;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const AmountInput({
    super.key,
    required this.state,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _displayTextFor(widget.state));
  }

  @override
  void didUpdateWidget(AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final externalText = _displayTextFor(widget.state);
    if (externalText != _controller.text) {
      _controller.value = TextEditingValue(
        text: externalText,
        selection: TextSelection.collapsed(offset: externalText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _displayTextFor(AmountFieldState state) => switch (state) {
    AmountEmpty() || AmountInvalid() => '',
    AmountBelowMinimum(:final rawDisplayValue) => rawDisplayValue,
    AmountValid(:final formattedValue) => formattedValue,
    AmountAboveLimit(:final formattedValue) => formattedValue,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    final Color underlineColor = switch (widget.state) {
      AmountEmpty() => colors.focusedUnderline,
      AmountValid() => colors.fieldUnderline,
      AmountBelowMinimum() ||
      AmountInvalid() ||
      AmountAboveLimit() => colors.errorUnderline,
    };

    final String? errorText = switch (widget.state) {
      AmountInvalid() => 'Invalid input',
      AmountBelowMinimum() => 'Enter at least ₹1',
      AmountAboveLimit() =>
        'UPI payments are capped at ₹1,00,000 per transaction',
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FSectionLabel('AMOUNT'),
        const SizedBox(height: 6),
        TextField(
          enabled: widget.enabled,
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: widget.onChanged,
          style: text.amountField,
          decoration: InputDecoration(
            isCollapsed: true,
            hintText: '₹0',
            hintStyle: text.amountField.copyWith(color: colors.mutedText),
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 6),
        Divider(height: 1, color: underlineColor),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText, style: text.amountError),
        ],
      ],
    );
  }
}
