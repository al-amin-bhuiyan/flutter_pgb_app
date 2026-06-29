import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/app_router.dart';
import 'core/theme/pgb_theme.dart';
import 'core/di/injection_container.dart';
import 'features/geofence/data/services/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();
  await sl<NotificationHelper>().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(328, 720),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Pgb App',
          themeMode: ThemeMode.system,
          theme: PgbTheme.lightTheme,
          darkTheme: PgbTheme.darkTheme,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
