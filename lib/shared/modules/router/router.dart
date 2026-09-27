import 'package:fave/shared/modules/router/i.router.dart' show RouterImpl;
import 'package:flutter/material.dart' show RouterConfig;

abstract class Router {
  factory Router() => RouterImpl();

  RouterConfig<Object>? routerConfig();
}

class RoutePaths {
  static const String payment = 'payment';

  ///Payments
  static const String pay = 'pay';
  static const String paymentConfirming = 'confirming';
  static const String paymentStatus = 'status';
}
