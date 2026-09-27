import 'package:auto_route/auto_route.dart'
    show AutoRouterConfig, RootStackRouter, RouteType, AutoRoute;
import 'package:fave/shared/modules/router/router.dart'
    as app
    show Router, RoutePaths;
import 'package:flutter/material.dart' show RouterConfig;

import 'i.router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View,Route')
class RouterImpl extends RootStackRouter implements app.Router {
  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  RouterConfig<Object>? routerConfig() => config();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: PaymentRoute.page,
      path: "/${app.RoutePaths.payment}",
      initial: true,
      children: [
        AutoRoute(page: PayRoute.page, path: app.RoutePaths.pay, initial: true),
        AutoRoute(
          page: PaymentConfirmingRoute.page,
          path: app.RoutePaths.paymentConfirming,
          keepHistory: false,
        ),
        AutoRoute(
          page: PaymentStatusRoute.page,
          path: app.RoutePaths.paymentStatus,
          keepHistory: false,
        ),
      ],
    ),
  ];
}
