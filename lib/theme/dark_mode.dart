import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey[900]!, // Dark background for surfaces
    primary: Colors.blueGrey[800]!, // Primary color for buttons, icons, etc.
    secondary: Colors.blueGrey[700]!, // Secondary color for smaller UI elements
    inversePrimary:
        Colors.blueGrey[500]!, // Lighter variant for inverse primary
  ),
  textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white, // Light text on dark backgrounds
        displayColor: Colors.white, // Light color for headlines
      ),
  iconTheme: const IconThemeData(color: Colors.white), // White icons for dark mode
);
