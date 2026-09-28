import 'package:fave/shared/modules/router/router.dart' as app show Router;
import 'package:fave/shared/modules/theme/theme.dart' show FAppTheme;
import 'package:flutter/material.dart';

void main() {
  runApp(const FApp());
}

class FApp extends StatelessWidget {
  const FApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = app.Router();
    return MaterialApp.router(
      routerConfig: router.routerConfig(),
      title: 'Fave',
      debugShowCheckedModeBanner: false,
      theme: FAppTheme.light(),
    );
  }
}
