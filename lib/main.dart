import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/auth_gate.dart';
import 'providers/expense_provider.dart';
import 'screens/onboarding_screen.dart';

// A global variable to easily access the Supabase client from anywhere in the app
final supabase = Supabase.instance.client;

Future<void> main() async {
  // Ensure Flutter is initialized before running async code.
  WidgetsFlutterBinding.ensureInitialized();
  // --- Supabase Initialization ---
  await Supabase.initialize(
    url: "https://zitayqerirlyvqsqseqr.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InppdGF5cWVyaXJseXZxc3FzZXFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5ODAyNDgsImV4cCI6MjA2NjU1NjI0OH0.NP09h25ADzr7q46io1lvoY-DjuZY30RWxo7xW6dshVM");

  // Get instance of SharedPreferences for the onboarding check.
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
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
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
        home: onboardingComplete ? const AuthGate() : OnboardingScreen(),
      ),
    );
  }
}
