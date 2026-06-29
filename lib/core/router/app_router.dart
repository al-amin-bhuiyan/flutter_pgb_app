import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/todos/presentation/screens/todos_screen.dart';

abstract class AppRouter {
  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String dashboardPath = '/dashboard';
  static const String todosPath = '/todos';

  static final GoRouter router = GoRouter(
    initialLocation: splashPath,
    routes: [
      GoRoute(
        path: splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: dashboardPath,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: todosPath,
        builder: (context, state) => const TodosScreen(),
      ),
    ],
  );
}
