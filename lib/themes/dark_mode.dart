import 'package:flutter/material.dart';

final ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,  // Dark but not pitch black for comfort
    primary: Colors.blueGrey.shade800, // Calm and professional color
    secondary: Colors.teal.shade700, // Soothing accent color for buttons
    inversePrimary: Colors.grey.shade300,
    onPrimary: Colors.white,  // Ensures text/icons are visible
    onSecondary: Colors.white,
    background: Colors.black,  // Dark mode-friendly background
  ),
  textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.grey.shade200, // Softer than pure white
        displayColor: Colors.white,
      ),
  scaffoldBackgroundColor: Colors.grey.shade900, // Dark but comfortable
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blueGrey.shade900,
    foregroundColor: Colors.white,
    elevation: 1,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.teal.shade700, // Matches the secondary color
    textTheme: ButtonTextTheme.primary,
  ),
);
