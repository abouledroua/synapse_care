import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const seed = Color.fromARGB(255, 235, 239, 240);
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: scheme.surface);
  }

  static ThemeData forIndex(int index) {
    final seed = _seedForIndex(index);
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: scheme.surface);
  }

  static Color _seedForIndex(int index) {
    if (index == 1) return const Color.fromARGB(255, 235, 239, 240); // blue
    if (index == 2) return const Color.fromARGB(255, 207, 175, 175); // red
    return const Color.fromARGB(255, 210, 231, 209); // green
  }
}
