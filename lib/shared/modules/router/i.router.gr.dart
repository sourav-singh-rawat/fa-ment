// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i5;
import 'package:fave/features/payment/domain/entities/payment.dart' as _i7;
import 'package:fave/features/payment/presentation/confirming_view/view.dart'
    as _i2;
import 'package:fave/features/payment/presentation/pay_view/view.dart' as _i1;
import 'package:fave/features/payment/presentation/status_view/view.dart'
    as _i3;
import 'package:fave/features/payment/presentation/view.dart' as _i4;
import 'package:flutter/material.dart' as _i6;

/// generated route for
/// [_i1.PayView]
class PayRoute extends _i5.PageRouteInfo<void> {
  const PayRoute({List<_i5.PageRouteInfo>? children})
    : super(PayRoute.name, initialChildren: children);

  static const String name = 'PayRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.PayView();
    },
  );
}

/// generated route for
/// [_i2.PaymentConfirmingView]
class PaymentConfirmingRoute
    extends _i5.PageRouteInfo<PaymentConfirmingRouteArgs> {
  PaymentConfirmingRoute({
    _i6.Key? key,
    required _i7.Payment paymentAttempt,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         PaymentConfirmingRoute.name,
         args: PaymentConfirmingRouteArgs(
           key: key,
           paymentAttempt: paymentAttempt,
         ),
         initialChildren: children,
       );

  static const String name = 'PaymentConfirmingRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentConfirmingRouteArgs>();
      return _i2.PaymentConfirmingView(
        key: args.key,
        paymentAttempt: args.paymentAttempt,
      );
    },
  );
}

class PaymentConfirmingRouteArgs {
  const PaymentConfirmingRouteArgs({this.key, required this.paymentAttempt});

  final _i6.Key? key;

  final _i7.Payment paymentAttempt;

  @override
  String toString() {
    return 'PaymentConfirmingRouteArgs{key: $key, paymentAttempt: $paymentAttempt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentConfirmingRouteArgs) return false;
    return key == other.key && paymentAttempt == other.paymentAttempt;
  }

  @override
  int get hashCode => key.hashCode ^ paymentAttempt.hashCode;
}

/// generated route for
/// [_i3.PaymentStatusView]
class PaymentStatusRoute extends _i5.PageRouteInfo<PaymentStatusRouteArgs> {
  PaymentStatusRoute({
    _i6.Key? key,
    required _i7.Payment payment,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         PaymentStatusRoute.name,
         args: PaymentStatusRouteArgs(key: key, payment: payment),
         initialChildren: children,
       );

  static const String name = 'PaymentStatusRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentStatusRouteArgs>();
      return _i3.PaymentStatusView(key: args.key, payment: args.payment);
    },
  );
}

class PaymentStatusRouteArgs {
  const PaymentStatusRouteArgs({this.key, required this.payment});

  final _i6.Key? key;

  final _i7.Payment payment;

  @override
  String toString() {
    return 'PaymentStatusRouteArgs{key: $key, payment: $payment}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentStatusRouteArgs) return false;
    return key == other.key && payment == other.payment;
  }

  @override
  int get hashCode => key.hashCode ^ payment.hashCode;
}

/// generated route for
/// [_i4.PaymentView]
class PaymentRoute extends _i5.PageRouteInfo<void> {
  const PaymentRoute({List<_i5.PageRouteInfo>? children})
    : super(PaymentRoute.name, initialChildren: children);

  static const String name = 'PaymentRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.PaymentView();
    },
  );
}
