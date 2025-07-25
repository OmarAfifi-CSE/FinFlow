import 'package:expense_manager/auth/signin_screen.dart';
import 'package:expense_manager/auth/signup_screen.dart';
import 'package:expense_manager/screens/category_management_screen.dart';
import 'package:expense_manager/screens/home_screen.dart';
import 'package:expense_manager/screens/main_screen.dart';
import 'package:expense_manager/screens/onboarding_screen.dart';
import 'package:expense_manager/screens/profile_screen.dart';
import 'package:expense_manager/screens/tag_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../providers/expense_provider.dart';
import 'app_routes.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterGenerationConfig {
  static GoRouter goRouter() => GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    initialLocation: AppRoutes.mainScreen,
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

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final expenseProvider = Provider.of<ExpenseProvider>(
            context,
            listen: false,
          );
          if (supabase.auth.currentUser != null &&
              !expenseProvider.isDataLoaded) {
            expenseProvider.fetchInitialData();
          }
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mainScreen,
                name: AppRoutes.mainScreen,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categoriesScreen,
                name: AppRoutes.categoriesScreen,
                builder: (context, state) => const CategoryManagementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.tagsScreen,
                name: AppRoutes.tagsScreen,
                builder: (context, state) => const TagManagementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profileScreen,
                name: AppRoutes.profileScreen,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) async {
      final loggedIn = supabase.auth.currentUser != null;
      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

      if (!onboardingComplete) {
        return state.matchedLocation == AppRoutes.onboardingScreen
            ? null
            : AppRoutes.onboardingScreen;
      }

      final isGoingToAuthScreens =
          state.matchedLocation == AppRoutes.loginScreen ||
          state.matchedLocation == AppRoutes.registerScreen;

      if (!loggedIn && !isGoingToAuthScreens) {
        return AppRoutes.loginScreen;
      }

      if (loggedIn && isGoingToAuthScreens) {
        return AppRoutes.mainScreen;
      }

      return null;
    },
  );
}
