import 'dart:async';

import 'package:flutter/material.dart';

import '../core/config/api_config.dart';
import '../services/patient_service.dart';
import 'auth_controller.dart';

class HomeController extends ChangeNotifier {
  HomeController({PatientService? patientService})
      : _patientService = patientService ?? PatientService();

  final PatientService _patientService;
  bool menuOpen = false;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  final TextEditingController searchController = TextEditingController();
  final ScrollController searchScrollController = ScrollController();
  Timer? _searchDebounce;
  bool isSearching = false;
  String? searchError;
  List<Map<String, dynamic>> searchResults = [];

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

  @override
  void dispose() {
    _clockTimer?.cancel();
    _searchDebounce?.cancel();
    searchController.dispose();
    searchScrollController.dispose();
    super.dispose();
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

  void searchPatients(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      isSearching = false;
      searchError = null;
      searchResults = [];
      notifyListeners();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      isSearching = true;
      searchError = null;
      notifyListeners();
      try {
        searchResults = await _patientService.searchPatients(query);
      } catch (_) {
        searchError = 'error';
        searchResults = [];
      } finally {
        isSearching = false;
        notifyListeners();
      }
    });
  }
}
