import 'package:expense_manager/auth/signin_screen.dart';
import 'package:expense_manager/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import 'app_routes.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }
}

class RouterGenerationConfig {
  static GoRouter goRouter() => GoRouter(
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    initialLocation: AppRoutes.homeScreen,
    routes: [
      GoRoute(
        path: AppRoutes.onboardingScreen,
        name: AppRoutes.onboardingScreen,
        builder: (context, state) => const OnboardingScreen(),
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
    redirect: (context, state) async {
      final loggedIn = supabase.auth.currentUser != null;

      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

      // القانون 1: لو onboarding مخلصش، وديه هناك الأول
      if (!onboardingComplete) {
        return state.matchedLocation == AppRoutes.onboardingScreen
            ? null
            : AppRoutes.onboardingScreen;
      }

      final isGoingToLoginOrRegister = state.matchedLocation == AppRoutes.loginScreen ||
          state.matchedLocation == AppRoutes.registerScreen;

      // القانون 2: لو المستخدم مش مسجل دخول وبيحاول يروح لصفحة محمية، وديه لصفحة الدخول
      if (!loggedIn && !isGoingToLoginOrRegister) {
        return AppRoutes.loginScreen;
      }

      // القانون 3: لو مسجل دخول وبيحاول يروح لصفحة الدخول، وديه للهوم
      if (loggedIn && isGoingToLoginOrRegister) {
        return AppRoutes.homeScreen;
      }

      // لو كل القوانين تمام، سيبه يكمل طريقه
      return null;
    },
  );
}
