import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key});

  static const _copy =
      "Don't pay again. If money has left your account, this will either "
      'complete or be refunded — never both.';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final layout = context.layout;

    return Container(
      width: double.infinity,
      padding: layout.noticePadding,
      decoration: BoxDecoration(
        color: colors.noticeBox,
        borderRadius: BorderRadius.circular(layout.noticeRadius),
      ),
      child: Text(
        _copy,
        style: context.text.checkingLink.copyWith(
          fontSize: 12.5,
          height: 17 / 12.5,
          fontWeight: FontWeight.w500,
          color: colors.primaryText,
        ),
      ),
    );
  }
}
