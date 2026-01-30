import 'dart:async';

import 'package:flutter/material.dart';

import '../core/config/api_config.dart';
import 'auth_controller.dart';

class HomeController extends ChangeNotifier {
  bool menuOpen = true;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  DateTime get now => _now;

  void startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  void stopClock() {
    _clockTimer?.cancel();
    _clockTimer = null;
  }

  void toggleMenu() {
    menuOpen = !menuOpen;
    notifyListeners();
  }

  String formatDate() {
    final day = _now.day.toString().padLeft(2, '0');
    final month = _now.month.toString().padLeft(2, '0');
    final year = _now.year.toString();
    return '$day/$month/$year';
  }

  String formatTime() {
    final hour = _now.hour.toString().padLeft(2, '0');
    final minute = _now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String? doctorName() {
    final user = AuthController.globalUser;
    if (user == null) return null;
    final name = (user['fullname'] ?? '').toString().trim();
    return name.isEmpty ? null : name;
  }

  String? clinicName() {
    final clinic = AuthController.globalClinic;
    if (clinic == null) return null;
    final name = (clinic['nom_cabinet'] ?? '').toString().trim();
    return name.isEmpty ? null : name;
  }

  String? userPhotoUrl() {
    final user = AuthController.globalUser;
    if (user == null) return null;
    final photo = (user['photo_url'] ?? '').toString();
    if (photo.isEmpty) return null;
    final baseUrl = ApiConfig.resolveBaseUrl();
    return '$baseUrl/photos/$photo';
  }
}
