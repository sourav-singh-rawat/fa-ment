import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

class FaveBottomSheet extends StatelessWidget {
  final Widget child;

  const FaveBottomSheet({super.key, required this.child});

  /// Shows [child] inside the shared sheet shell using Flutter's own modal
  /// bottom sheet, which already provides the scrim, drag handle, and
  /// slide-up/slide-down transition. `showModalBottomSheet`'s default
  /// transition duration is 250ms — matching the specification — so no
  /// custom AnimationController is needed for the shell itself.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget Function() builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FaveBottomSheet(child: builder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    return Padding(padding: layout.sheetPadding, child: child);
  }
}
