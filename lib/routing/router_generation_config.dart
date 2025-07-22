import 'package:expense_manager/auth/signin_screen.dart';
import 'package:expense_manager/auth/signup_screen.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_gate.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import 'app_routes.dart';

class RouterGenerationConfig {
  static GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.onboardingScreen,
    routes: [
      GoRoute(
        path: AppRoutes.onboardingScreen,
        name: AppRoutes.onboardingScreen,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.authGate,
        name: AppRoutes.authGate,
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: AppRoutes.loginScreen,
        name: AppRoutes.loginScreen,
        builder: (context, state) => const SigninScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerScreen,
        name: AppRoutes.registerScreen,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.homeScreen,
        name: AppRoutes.homeScreen,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
