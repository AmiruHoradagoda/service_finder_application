import 'package:service_finder_application/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_finder_application/core/theme/dark_mode.dart';
import 'package:service_finder_application/core/theme/light_mode.dart';
import 'package:service_finder_application/routes/app_routes.dart';
import 'package:service_finder_application/routes/auth_navigation.dart';

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthNavigation(
        AuthService().sessionChanges,
      ),
      child: Consumer<AuthNavigation>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: auth.navigatorKey,
          onGenerateInitialRoutes: (_) => [AppRoutes.initialRoute(auth)],
          // Navigation uses typed methods rather than incoming named routes.
          onGenerateRoute: (_) => null,
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: ThemeMode.system,
        ),
      ),
    );
  }
}
