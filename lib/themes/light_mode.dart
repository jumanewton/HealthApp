import 'package:flutter/material.dart';

final ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white, // Clean and fresh background
    primary: Colors.blueGrey.shade100, // Soft, calming color
    secondary: Colors.teal.shade400, // Medical-themed accent color
    inversePrimary: Colors.grey.shade900,
    background: Colors.grey.shade100, // Subtle contrast for backgrounds
    onPrimary: Colors.black, // Ensures readability on primary colors
    onSecondary: Colors.white, // Good contrast for secondary elements
  ),
  textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.grey.shade900, // Better contrast for readability
        displayColor: Colors.black,
      ),
  scaffoldBackgroundColor: Colors.white, // Clean and bright
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blueGrey.shade200, // Soft color for header
    foregroundColor: Colors.black,
    elevation: 1,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.teal.shade400, // Matches secondary color
    textTheme: ButtonTextTheme.primary,
  ),
);
