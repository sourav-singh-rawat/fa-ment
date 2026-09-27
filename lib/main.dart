import 'package:fave/shared/modules/router/router.dart' as app show Router;
import 'package:fave/shared/modules/theme/i.theme.dart' show FaveAppTheme;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = app.Router();
    return MaterialApp.router(
      routerConfig: router.routerConfig(),
      title: 'Fave',
      debugShowCheckedModeBanner: false,
      theme: FaveAppTheme.light(),
    );
  }
}
