import 'dart:math' as math;

import 'package:fave/features/payment/presentation/confirming_view/controller/payment_confirm_cubit.dart'
    show
        PaymentConfirmCubit,
        kConfirmingDeadlineDuration,
        PaymentConfirmState,
        PaymentFinalStatus;
import 'package:fave/features/payment/presentation/confirming_view/view.dart'
    show PaymentConfirmNavigatorMixin;
import 'package:fave/shared/modules/theme/theme.dart' show FThemeContext;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext, BlocListener;

class CountdownRing extends StatefulWidget {
  const CountdownRing({super.key});

  @override
  State<CountdownRing> createState() => _CountdownRingState();
}

class _RepaintSignal extends ChangeNotifier {
  void tick() => notifyListeners();
}

const _manualCompletionDuration = Duration(milliseconds: 250);

class _CountdownRingState extends State<CountdownRing>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        PaymentConfirmNavigatorMixin {
  late final PaymentConfirmCubit _cubit;
  late final Ticker _ticker;

  final _repaint = _RepaintSignal();
  final ValueNotifier<int> _seconds = ValueNotifier<int>(0);

  double _progress = 0;

  bool _isCompletingManually = false;
  double _manualStartProgress = 0;

  @override
  void initState() {
    super.initState();

    _cubit = context.read<PaymentConfirmCubit>();

    _sampleClock();
    _ticker = createTicker((elapsed) {
      if (_isCompletingManually) {
        _tickManualCompletion(elapsed);
      } else {
        _sampleClock();
      }
    });

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
      if (_isCompletingManually) {
        _finishManualCompletion();
        return;
      }

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

    return BlocListener<PaymentConfirmCubit, PaymentConfirmState>(
      listenWhen: _listenWhen,
      listener: _listener,
      child: RepaintBoundary(
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
      ),
    );
  }

  bool _listenWhen(PaymentConfirmState p, PaymentConfirmState c) {
    return c is PaymentFinalStatus && p is! PaymentFinalStatus;
  }

  void _listener(BuildContext context, PaymentConfirmState state) {
    if (state is PaymentFinalStatus) {
      _completeProgressManually();
    }
  }

  void _completeProgressManually() {
    if (_isCompletingManually) return;

    _ticker.stop();

    if (_progress <= 0) {
      _finishManualCompletion();
      return;
    }

    _isCompletingManually = true;
    _manualStartProgress = _progress;
    _ticker.start(); // Elapsed time starts at zero.
  }

  void _tickManualCompletion(Duration elapsed) {
    final fraction =
        (elapsed.inMicroseconds / _manualCompletionDuration.inMicroseconds)
            .clamp(0.0, 1.0);

    final easedFraction = Curves.easeOut.transform(fraction);
    _progress = _manualStartProgress * (1 - easedFraction);
    _repaint.tick();

    final nextSeconds = (_progress * kConfirmingDeadlineDuration.inSeconds)
        .ceil();
    if (_seconds.value != nextSeconds) {
      _seconds.value = nextSeconds;
    }

    if (fraction >= 1) {
      _finishManualCompletion();
    }
  }

  void _finishManualCompletion() {
    _ticker.stop();
    _progress = 0;
    _seconds.value = 0;
    _repaint.tick();
    withdrawNavigationGuard(context);
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
