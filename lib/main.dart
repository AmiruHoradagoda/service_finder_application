import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/app/app.dart';
import 'package:service_finder_application/firebase_options.dart';
export 'package:service_finder_application/app/app.dart' show RootApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RootApp());
}
