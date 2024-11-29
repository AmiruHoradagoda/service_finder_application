import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/auth/auth.dart';
import 'package:service_finder_application/auth/login_or_register.dart';
import 'package:service_finder_application/firebase_options.dart';
import 'package:service_finder_application/pages/home_page.dart';
import 'package:service_finder_application/pages/profile_page.dart';
import 'package:service_finder_application/pages/users_page.dart';
import 'package:service_finder_application/theme/dark_mode.dart';
import 'package:service_finder_application/theme/light_mode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      enabled: true, // Enable or disable DevicePreview here
      builder: (context) => const RootApp(), // Wrap your app
    ),
  );
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery:
          true, // Allows DevicePreview to simulate different screen sizes
      locale:
          DevicePreview.locale(context), // Sets the locale for DevicePreview
      builder: DevicePreview.appBuilder, // Enables the preview builder
      home: const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => HomePage(),
        '/profile_page': (context) => ProfilePage(),
        '/users_page': (context) => const UsersPage(),
      },
    );
  }
}
