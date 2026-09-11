import 'package:flutter/material.dart';

const gold = Color(0xFFFFC83D);
const ink = Color(0xFF101213);
final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: gold,
    brightness: Brightness.dark,
    primary: gold,
    onPrimary: ink,
    surface: const Color(0xFF1C1F20),
  ),
  scaffoldBackgroundColor: ink,
  appBarTheme: const AppBarTheme(backgroundColor: ink, centerTitle: false),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
);
