import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class NoteInput extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const NoteInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<NoteInput> createState() => _NoteInputState();
}

class _NoteInputState extends State<NoteInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(NoteInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          enabled: widget.enabled,
          controller: _controller,
          maxLength: 40,
          maxLines: 1,
          buildCounter: (
            _, {
            required currentLength,
            required isFocused,
            maxLength,
          }) => null,
          onChanged: widget.onChanged,
          style: text.noteField,
          decoration: InputDecoration(
            isCollapsed: true,
            hintText: 'Add a note (optional)',
            hintStyle: text.noteField.copyWith(color: colors.mutedText),
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 1, color: colors.fieldUnderline),
      ],
    );
  }
}
