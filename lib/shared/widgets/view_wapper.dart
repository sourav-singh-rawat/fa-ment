import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class FView extends StatelessWidget {
  const FView({
    super.key,
    required this.body,
    this.resizeToAvoidBottomInset = false,
  });

  final Widget body;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: Padding(padding: context.layout.screenPadding, child: body),
      ),
    );
  }
}
