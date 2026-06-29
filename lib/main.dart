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
      themeMode: ThemeMode.system,
      theme: PgbTheme.lightTheme,
      darkTheme: PgbTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
