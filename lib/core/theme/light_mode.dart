import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white, // Light background for surfaces
    primary: Colors.blue[300]!, // Primary color for buttons, icons, etc.
    secondary: Colors.blue[200]!, // Secondary color for smaller UI elements
    inversePrimary: Colors.blue[700]!, // Darker variant for inverse primary
  ),
  textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black, // Dark text on light backgrounds
        displayColor: Colors.black, // Dark color for headlines
      ),
  iconTheme:
      const IconThemeData(color: Colors.black), // Black icons for light mode
);
