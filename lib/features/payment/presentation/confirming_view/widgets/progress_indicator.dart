part of payment_confirming_view;

class _ProgressIndicator extends StatefulWidget {
  const _ProgressIndicator({super.key});

  @override
  State<_ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<_ProgressIndicator>
    with WidgetsBindingObserver {
  Timer? _ticker;

  late final PaymentConfirmCubit _paymentConfirmCubit;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _paymentConfirmCubit = context.read<PaymentConfirmCubit>();
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();

    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;

      final remaining = _remaining;

      if (remaining <= Duration.zero) {
        _ticker?.cancel();
      }

      setState(() {});
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Duration get _remaining {
    final deadline = _paymentConfirmCubit.confirmingDeadlineAt;

    final remaining = deadline.difference(DateTime.now());

    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get _progress {
    final remaining = _remaining.inMilliseconds;
    final total = kConfirmingDeadlineDuration.inMilliseconds;

    return (remaining / total).clamp(0.0, 1.0);
  }

  int get _remainingSeconds {
    return (_remaining.inMilliseconds / 1000).ceil();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Recalculate from the real clock.
      _startTicker();
      setState(() {});
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopTicker();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(value: _progress, strokeWidth: 8),
          Text(
            '${_remainingSeconds}s',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
