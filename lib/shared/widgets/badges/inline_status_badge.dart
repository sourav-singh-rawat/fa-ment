import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

enum InlineBadgeKind { checking, unresolved }

class InlineStatusBadge extends StatelessWidget {
  final InlineBadgeKind kind;
  const InlineStatusBadge({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final label = switch (kind) {
      InlineBadgeKind.checking => 'CHECKING',
      InlineBadgeKind.unresolved => 'UNRESOLVED',
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
      decoration: BoxDecoration(
        color: colors.recentBadgeBackground,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: text.recentBadge),
    );
  }
}
