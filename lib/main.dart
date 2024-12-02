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
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => HomePage(),
        '/profile_page': (context) => ProfilePage(),
        '/users_page': (context) => UsersPage(),
      },
    );
  }
}
