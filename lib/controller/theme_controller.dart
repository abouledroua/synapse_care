import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constant/app_theme.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const _storageKey = 'theme_index';

  int _index = 1;

  int get index => _index;

  ThemeData get theme => AppTheme.forIndex(_index);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _index = prefs.getInt(_storageKey) ?? _index;
    notifyListeners();
  }

  void setIndex(int index) {
    if (_index == index) return;
    _index = index;
    _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, _index);
  }
}
