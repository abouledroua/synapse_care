import 'package:flutter/material.dart';

import 'locale_controller.dart';
import 'theme_controller.dart';

class SettingsController extends ChangeNotifier {
  SettingsController() {
    LocaleController.instance.addListener(_forwardChange);
    ThemeController.instance.addListener(_forwardChange);
  }

  String get currentLanguageCode =>
      LocaleController.instance.locale?.languageCode ?? 'en';

  int get themeIndex => ThemeController.instance.index;

  Future<void> setLanguage(String code) async {
    await LocaleController.instance.setLocale(Locale(code));
    notifyListeners();
  }

  void setTheme(int index) {
    ThemeController.instance.setIndex(index);
    notifyListeners();
  }

  void _forwardChange() => notifyListeners();

  @override
  void dispose() {
    LocaleController.instance.removeListener(_forwardChange);
    ThemeController.instance.removeListener(_forwardChange);
    super.dispose();
  }
}

