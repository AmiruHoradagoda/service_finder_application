import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/screens/auth.dart';
import 'package:service_finder_application/core/theme/dark_mode.dart';
import 'package:service_finder_application/core/theme/light_mode.dart';
import 'package:service_finder_application/routes/app_routes.dart';

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: ThemeMode.system,
      routes: AppRoutes.routes,
    );
  }
}
