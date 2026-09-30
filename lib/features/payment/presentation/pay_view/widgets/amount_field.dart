import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:fave/shared/utils/extensions/num_ext.dart';
import 'package:fave/shared/widgets/selection_label.dart' show FSectionLabel;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter;

sealed class AmountFieldState {
  final int value;
  const AmountFieldState(this.value);

  String get formattedValue => value.formatIndianRupees;
}

final class AmountEmpty extends AmountFieldState {
  const AmountEmpty() : super(0);

  @override
  String get formattedValue => '';
}

final class AmountValid extends AmountFieldState {
  const AmountValid(super.value);
}

final class AmountBelowMinimum extends AmountFieldState {
  const AmountBelowMinimum(super.value);
}

final class AmountAboveLimit extends AmountFieldState {
  const AmountAboveLimit(super.value);
}

class AmountInput extends StatefulWidget {
  final AmountFieldState state;
  final bool enabled;
  final ValueChanged<int> onChanged;

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
  static const _formatter = _IndianRupeeInputFormatter();
  late final TextEditingController _controller;

  int? _amountOf(AmountFieldState s) => s is AmountEmpty ? null : s.value;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.formattedValue);
  }

  @override
  void didUpdateWidget(AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_IndianRupeeInputFormatter.parse(_controller.text) ==
        _amountOf(widget.state)) {
      return;
    }
    final text = widget.state.formattedValue;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void onChanged(String value) {
    final amount = _IndianRupeeInputFormatter.parse(value) ?? 0;
    widget.onChanged(amount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    final Color underlineColor = switch (widget.state) {
      AmountEmpty() || AmountValid() => colors.fieldUnderline,
      AmountBelowMinimum() || AmountAboveLimit() => colors.errorUnderline,
    };

    final String? errorText = switch (widget.state) {
      AmountBelowMinimum() => 'Enter at least ${1.formatIndianRupees}',
      AmountAboveLimit() =>
        'UPI payments are capped at ${100000.formatIndianRupees} per transaction',
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
          inputFormatters: const [_formatter],
          onChanged: onChanged,
          style: text.amountField,
          decoration: InputDecoration(
            isCollapsed: true,
            hintText: 0.formatIndianRupees,
            hintStyle: text.amountField.copyWith(color: colors.mutedText),
            border: _defaultTransparentBoarder,
            errorBorder: _defaultTransparentBoarder,
            focusedBorder: _defaultTransparentBoarder,
            enabledBorder: _defaultTransparentBoarder,
            disabledBorder: _defaultTransparentBoarder,
          ),
        ),
        Divider(height: 1, color: underlineColor),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText, style: text.amountError),
        ],
      ],
    );
  }
}

const _defaultTransparentBoarder = UnderlineInputBorder(
  borderSide: BorderSide(color: Colors.transparent, width: 0),
);

const _safeMaxDigits = 9;

class _IndianRupeeInputFormatter extends TextInputFormatter {
  const _IndianRupeeInputFormatter();

  static final _nonDigit = RegExp(r'\D');
  static final _digit = RegExp(r'\d');

  static int? parse(String text) {
    final digits = text.replaceAll(_nonDigit, '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(_nonDigit, '');
    if (digits.isEmpty) return TextEditingValue.empty;
    if (digits.length > _safeMaxDigits) return oldValue;

    final amount = int.parse(digits);
    final formatted = amount.formatIndianRupees;

    final leadingZeros = digits.length - amount.toString().length;
    final caret = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    var digitsBeforeCaret =
        newValue.text.substring(0, caret).replaceAll(_nonDigit, '').length -
        leadingZeros;
    if (digitsBeforeCaret < 0) digitsBeforeCaret = 0;

    var offset = formatted.length;
    if (digitsBeforeCaret == 0) {
      offset = formatted.indexOf(_digit);
    } else {
      var seen = 0;
      for (var i = 0; i < formatted.length; i++) {
        if (_digit.hasMatch(formatted[i]) && ++seen == digitsBeforeCaret) {
          offset = i + 1;
          break;
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
