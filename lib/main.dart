import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/expense_provider.dart';
import 'screens/onboarding_screen.dart';
import 'package:expense_manager/screens/signin_screen.dart';

Future<void> main() async {
  // Ensure Flutter is initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Get instance of SharedPreferences.
  final prefs = await SharedPreferences.getInstance();
  // Check if onboarding has been completed. Default to false if not found.
  final bool onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(MyApp(prefs: prefs, onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final bool onboardingComplete;

  const MyApp({
    super.key,
    required this.prefs,
    required this.onboardingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Pass the SharedPreferences instance to your provider.
        ChangeNotifierProvider(create: (_) => ExpenseProvider(prefs)),
      ],
      child: MaterialApp(
        title: 'FinFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.teal,
          ).copyWith(secondary: Colors.white),
        ),
        home: onboardingComplete ? const SigninScreen() : OnboardingScreen(),
      ),
    );
  }
}
