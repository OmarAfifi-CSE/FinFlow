import 'package:expense_manager/providers/theme_provider.dart';
import 'package:expense_manager/routing/router_generation_config.dart';
import 'package:expense_manager/styling/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/expense_provider.dart';
import 'widgets/connectivity_monitor.dart';

// A global variable to easily access the Supabase client from anywhere in the app
final supabase = Supabase.instance.client;

Future<void> main() async {
  // Ensure Flutter is initialized before running async code.
  WidgetsFlutterBinding.ensureInitialized();

  // --- 1. Load Saved Theme ---
  final prefs = await SharedPreferences.getInstance();
  final String themeName =
      prefs.getString(ThemeProvider.themeKey) ?? ThemeMode.light.name;
  final initialThemeMode = ThemeMode.values.firstWhere(
        (e) => e.name == themeName,
    orElse: () => ThemeMode.light,
  );

  // Initialize Supabase.
  await Supabase.initialize(
    url: "https://fpeynvsshkecovrkuwfx.supabase.co",
    anonKey:
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZwZXludnNzaGtlY292cmt1d2Z4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2MjQ2ODcsImV4cCI6MjA2NjIwMDY4N30.RKoKFz-AEtw4rz-Fge2h3nHX_Eu8Wmjfygbugcz_EB8",
    // This tells the Supabase client to use the simpler token flow, which is compatible with the web-based password reset page.
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  runApp(MyApp(initialThemeMode: initialThemeMode));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialThemeMode)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'FinFlow',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            // The builder property ensures that ConnectivityMonitor has access to the context provided by MaterialApp, including ScaffoldMessenger.
            builder: (context, child) {
              return ConnectivityMonitor(
                // The 'child' here is the entire navigation stack of the app.
                child: child!,
              );
            },
            routerConfig: RouterGenerationConfig.goRouter(),
          );
        },
      ),
    );
  }
}
