import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const seed = Color(0xFF7B5AA6);
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: scheme.surface);
  }

  static ThemeData forIndex(int index) {
    final seed = _seedForIndex(index);
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: scheme.surface);
  }

  static Color _seedForIndex(int index) {
    switch (index) {
      case 1:
        return const Color(0xFF7B5AA6); // purple
      case 2:
        return const Color(0xFF2F6FA5); // blue
      case 3:
        return const Color(0xFFC45E8B); // pink
      case 4:
        return const Color(0xFF3E8A5A); // green
      default:
        return const Color(0xFF7B5AA6);
    }
  }
}
