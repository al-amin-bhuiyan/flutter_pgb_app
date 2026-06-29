import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/pgb_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pgb App',
      theme: PgbTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
