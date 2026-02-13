import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeData>(ThemeNotifier.new);
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

class ThemeNotifier extends Notifier<ThemeData> {
  @override
  ThemeData build() => ThemeData.light();

  void setTheme(ThemeData theme) {
    state = theme;
  }
}

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void setLocale(Locale locale) {
    state = locale;
  }
}
