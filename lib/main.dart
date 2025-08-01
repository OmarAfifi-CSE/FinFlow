import 'package:expense_manager/routing/router_generation_config.dart';
import 'package:expense_manager/styling/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/expense_provider.dart';
import 'widgets/connectivity_monitor.dart';

// A global variable to easily access the Supabase client from anywhere in the app
final supabase = Supabase.instance.client;

Future<void> main() async {
  // Ensure Flutter is initialized before running async code.
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: MaterialApp.router(
        title: 'FinFlow',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        // The builder property ensures that ConnectivityMonitor has access to the context provided by MaterialApp, including ScaffoldMessenger.
        builder: (context, child) {
          return ConnectivityMonitor(
            // The 'child' here is the entire navigation stack of the app.
            child: child!,
          );
        },
        routerConfig: RouterGenerationConfig.goRouter(),
      ),
    );
  }
}
