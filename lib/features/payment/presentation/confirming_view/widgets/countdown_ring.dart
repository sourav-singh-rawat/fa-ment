import 'dart:math' as math;

import 'package:fave/features/payment/presentation/confirming_view/controller/payment_confirm_cubit.dart'
    show PaymentConfirmCubit, kConfirmingDeadlineDuration;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

class CountdownRing extends StatefulWidget {
  const CountdownRing({super.key});

  @override
  State<CountdownRing> createState() => _CountdownRingState();
}

class _RepaintSignal extends ChangeNotifier {
  void tick() => notifyListeners();
}

class _CountdownRingState extends State<CountdownRing>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final PaymentConfirmCubit _cubit;
  late final Ticker _ticker;

  final _repaint = _RepaintSignal();
  final ValueNotifier<int> _seconds = ValueNotifier<int>(0);

  double _progress = 0;

  @override
  void initState() {
    super.initState();

    _cubit = context.read<PaymentConfirmCubit>();

    _sampleClock();
    _ticker = createTicker((_) => _sampleClock());

    WidgetsBinding.instance.addObserver(this);
    if (_progress > 0) _ticker.start();
  }

  void _sampleClock() {
    final remaining = _cubit.confirmingDeadlineAt.difference(DateTime.now());
    final micros = math.max(0, remaining.inMicroseconds);
    final total = kConfirmingDeadlineDuration.inMicroseconds;

    _progress = total == 0 ? 0 : (micros / total).clamp(0.0, 1.0);

    _repaint.tick();

    final nextSeconds = (micros / Duration.microsecondsPerSecond).ceil();
    if (_seconds.value != nextSeconds) {
      _seconds.value = nextSeconds;
    }

    if (_progress == 0 && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sampleClock();

      if (_progress > 0 && !_ticker.isActive) {
        _ticker.start();
      } else if (_progress == 0 && _ticker.isActive) {
        _ticker.stop();
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_ticker.isActive) {
        _ticker.stop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _repaint.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final layout = context.layout;

    return RepaintBoundary(
      child: SizedBox.square(
        dimension: layout.ringSize,
        child: CustomPaint(
          painter: _RingPainter(
            repaint: _repaint,
            progress: () => _progress,
            trackColor: colors.countdownTrack,
            progressColor: colors.countdownProgress,
            strokeWidth: layout.ringStrokeWidth,
          ),
          child: Center(
            child: ValueListenableBuilder<int>(
              valueListenable: _seconds,
              builder: (context, seconds, _) =>
                  Text('${seconds}s', style: context.text.ringSeconds),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double Function() progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required Listenable repaint,
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress().clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.progress != progress;
}

// class CountdownRing extends StatelessWidget {
//   final Listenable repaint;
//   final double Function() progressOf;
//   final int Function() secondsOf;
//
//   const CountdownRing({
//     super.key,
//     required this.repaint,
//     required this.progressOf,
//     required this.secondsOf,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final layout = context.layout;
//     final text = context.text;
//
//     return RepaintBoundary(
//       child: SizedBox(
//         width: layout.ringSize,
//         height: layout.ringSize,
//         child: CustomPaint(
//           painter: _RingPainter(
//             repaint: repaint,
//             progressOf: progressOf,
//             trackColor: colors.countdownTrack,
//             progressColor: colors.countdownProgress,
//             strokeWidth: layout.ringStrokeWidth,
//           ),
//           child: Center(
//             child: _TickingSecondsLabel(
//               repaint: repaint,
//               secondsOf: secondsOf,
//               style: text.ringSeconds,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _TickingSecondsLabel extends AnimatedWidget {
//   final int Function() secondsOf;
//   final TextStyle style;
//   const _TickingSecondsLabel({
//     required Listenable repaint,
//     required this.secondsOf,
//     required this.style,
//   }) : super(listenable: repaint);
//
//   @override
//   Widget build(BuildContext context) {
//     return Text('${secondsOf()}s', style: style);
//   }
// }
//
// class _RingPainter extends CustomPainter {
//   final double Function() progressOf;
//   final Color trackColor;
//   final Color progressColor;
//   final double strokeWidth;
//
//   _RingPainter({
//     required Listenable repaint,
//     required this.progressOf,
//     required this.trackColor,
//     required this.progressColor,
//     required this.strokeWidth,
//   }) : super(repaint: repaint);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = size.center(Offset.zero);
//     final radius = (size.shortestSide - strokeWidth) / 2;
//
//     final trackPaint = Paint()
//       ..color = trackColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.butt;
//     canvas.drawCircle(center, radius, trackPaint);
//
//     final progressPaint = Paint()
//       ..color = progressColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.butt;
//
//     const startAngle = -90 * (3.14159265358979 / 180); // 12 o'clock
//     final sweep = 2 * 3.14159265358979 * progressOf().clamp(0.0, 1.0);
//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius),
//       startAngle,
//       sweep,
//       false,
//       progressPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant _RingPainter oldDelegate) => false; // repaint listenable drives it
// }
