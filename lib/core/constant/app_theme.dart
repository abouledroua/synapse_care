import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const seed = Color(0xFFA895E3);
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: scheme.surface);
  }

  static ThemeData forIndex(int index) {
    final seed = _seedForIndex(index);
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: scheme.surface);
  }

  static Color _seedForIndex(int index) {
    if (index == 1) return const Color(0xFFA895E3); // purple
    if (index == 2) return const Color.fromARGB(255, 216, 138, 138); // red
    return const Color.fromARGB(255, 154, 189, 153); // green
  }
}
