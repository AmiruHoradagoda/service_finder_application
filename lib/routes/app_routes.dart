import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/screens/login_or_register_screen.dart';
import 'package:service_finder_application/features/home/screens/home_screen.dart';
import 'package:service_finder_application/features/profile/screens/profile_screen.dart';
import 'package:service_finder_application/features/chat/screens/users_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const loginRegister = '/login_register_page';
  static const home = '/home_page';
  static const profile = '/profile_page';
  static const users = '/users_page';

  static final Map<String, WidgetBuilder> routes = {
    loginRegister: (context) => const LoginOrRegister(),
    home: (context) => HomePage(),
    profile: (context) => ProfilePage(),
    users: (context) => UsersPage(),
  };
}
