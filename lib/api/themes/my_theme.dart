import 'package:flutter/material.dart';

// Color primario azul - del círculo del login
const Color primaryBlue = Color.fromARGB(255, 6, 126, 187);

//ligth theme
ThemeData lighTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryBlue,
    brightness: Brightness.light,
    ),
    useMaterial3: true,
);

//dark theme 
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryBlue,
    brightness: Brightness.dark,
    ),
    useMaterial3: true,
);