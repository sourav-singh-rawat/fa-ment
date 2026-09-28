import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';

enum BadgeKind { success, failed, waiting }

class StatusBadge extends StatelessWidget {
  final BadgeKind kind;

  final double waitingProgress;

  const StatusBadge({
    super.key,
    required this.kind,
    this.waitingProgress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final layout = context.layout;

    return SizedBox(
      width: layout.badgeSize,
      height: layout.badgeSize,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: switch (kind) {
            BadgeKind.success => _SuccessCheck(color: colors.primaryCta),
            BadgeKind.failed => _FailedCross(
              circleColor: colors.failedBadge,
              crossColor: colors.failedCross,
            ),
            BadgeKind.waiting => _WaitingRing(
              trackColor: colors.avatarAndWaitingRing,
              progressColor: colors.avatarAndWaitingRing,
              progress: waitingProgress,
            ),
          },
        ),
      ),
    );
  }
}

class _SuccessCheck extends StatelessWidget {
  final Color color;
  const _SuccessCheck({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: CustomPaint(painter: _CheckPainter(circleColor: color)),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final Color circleColor;
  const _CheckPainter({required this.circleColor});

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()..color = circleColor;
    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2,
      circlePaint,
    );

    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.74, size.height * 0.34);

    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.circleColor != circleColor;
}

class _FailedCross extends StatelessWidget {
  final Color circleColor;
  final Color crossColor;
  const _FailedCross({required this.circleColor, required this.crossColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: CustomPaint(
        painter: _CrossPainter(
          circleColor: circleColor,
          crossColor: crossColor,
        ),
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  final Color circleColor;
  final Color crossColor;
  const _CrossPainter({required this.circleColor, required this.crossColor});

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()..color = circleColor;
    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2,
      circlePaint,
    );

    final crossPaint = Paint()
      ..color = crossColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final inset = size.width * 0.30;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      crossPaint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrossPainter oldDelegate) =>
      oldDelegate.circleColor != circleColor ||
      oldDelegate.crossColor != crossColor;
}

class _WaitingRing extends StatelessWidget {
  final Color trackColor;
  final Color progressColor;
  final double progress;
  const _WaitingRing({
    required this.trackColor,
    required this.progressColor,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 64,
      child: CustomPaint(
        painter: _WaitingRingPainter(
          trackColor: trackColor,
          progressColor: progressColor,
          progress: progress,
        ),
      ),
    );
  }
}

class _WaitingRingPainter extends CustomPainter {
  final Color trackColor;
  final Color progressColor;
  final double progress;
  const _WaitingRingPainter({
    required this.trackColor,
    required this.progressColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const startAngle = -90 * (3.14159265358979 / 180);
    final sweep = 2 * 3.14159265358979 * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WaitingRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
