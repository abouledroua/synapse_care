import 'dart:async';

import 'package:flutter/material.dart';

import '../core/config/api_config.dart';
import '../services/appointment_service.dart';
import '../services/patient_service.dart';
import 'auth_controller.dart';

class HomeController extends ChangeNotifier {
  HomeController({PatientService? patientService, AppointmentService? appointmentService})
    : _patientService = patientService ?? PatientService(),
      _appointmentService = appointmentService ?? AppointmentService();

  final PatientService _patientService;
  final AppointmentService _appointmentService;
  bool menuOpen = false;
  Timer? _clockTimer;
  Timer? _patientCountTimer;
  DateTime _now = DateTime.now();
  final TextEditingController searchController = TextEditingController();
  final ScrollController searchScrollController = ScrollController();
  Timer? _searchDebounce;
  bool isSearching = false;
  String? searchError;
  List<Map<String, dynamic>> searchResults = [];
  int? patientCount;
  int? todayAppointmentCount;
  Map<String, dynamic>? nextTodayAppointment;

  DateTime get now => _now;

  void startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
    _patientCountTimer?.cancel();
    loadPatientCount();
    loadTodayAppointmentCount();
    _patientCountTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadPatientCount();
      loadTodayAppointmentCount();
    });
  }

  void stopClock() {
    _clockTimer?.cancel();
    _clockTimer = null;
    _patientCountTimer?.cancel();
    _patientCountTimer = null;
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _patientCountTimer?.cancel();
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

  int? _cabinetId() {
    final raw = AuthController.globalClinic?['id_cabinet'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  int? _userId() {
    return AuthController.globalUserId;
  }

  String? userPhotoUrl() {
    final user = AuthController.globalUser;
    if (user == null) return null;
    final photo = (user['photo_url'] ?? '').toString();
    if (photo.isEmpty) return null;
    final baseUrl = ApiConfig.resolveBaseUrl();
    return '$baseUrl/photos/$photo';
  }

  Future<void> loadPatientCount() async {
    try {
      final cabinetId = _cabinetId();
      final userId = _userId();
      if (cabinetId == null || userId == null) {
        patientCount = null;
      } else {
        patientCount = await _patientService.fetchPatientCount(cabinetId: cabinetId, userId: userId);
      }
    } catch (_) {
      patientCount = null;
    }
    notifyListeners();
  }

  Future<void> loadTodayAppointmentCount() async {
    try {
      final cabinetId = _cabinetId();
      final userId = _userId();
      if (cabinetId == null || userId == null) {
        todayAppointmentCount = null;
        nextTodayAppointment = null;
      } else {
        final rows = await _appointmentService.fetchAppointments(cabinetId: cabinetId, userId: userId);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final count = rows.where((item) {
          final etat = int.tryParse('${item['etat_rdv'] ?? ''}');
          if (etat != 0 && etat != 1) return false;
          final date = _parseDateOnly(item['date_rdv']);
          if (date == null) return false;
          return date.year == today.year && date.month == today.month && date.day == today.day;
        }).length;
        todayAppointmentCount = count;

        final todayRows = rows.where((item) {
          final etat = int.tryParse('${item['etat_rdv'] ?? ''}');
          if (etat != 0 && etat != 1) return false;
          final num = int.tryParse('${item['num_rdv'] ?? ''}') ?? 0;
          if (num <= 0) return false;
          final date = _parseDateOnly(item['date_rdv']);
          if (date == null) return false;
          return date.year == today.year && date.month == today.month && date.day == today.day;
        }).toList();
        if (todayRows.isEmpty) {
          nextTodayAppointment = null;
        } else {
          todayRows.sort((a, b) {
            final na = int.tryParse('${a['num_rdv'] ?? ''}') ?? 0;
            final nb = int.tryParse('${b['num_rdv'] ?? ''}') ?? 0;
            return na.compareTo(nb);
          });
          nextTodayAppointment = Map<String, dynamic>.from(todayRows.first);
        }
      }
    } catch (_) {
      todayAppointmentCount = null;
      nextTodayAppointment = null;
    }
    notifyListeners();
  }

  void clearDashboardData() {
    patientCount = null;
    todayAppointmentCount = null;
    nextTodayAppointment = null;
    notifyListeners();
  }

  Future<void> refreshDashboardDataNow() async {
    await loadPatientCount();
    await loadTodayAppointmentCount();
  }

  DateTime? _parseDateOnly(dynamic raw) {
    if (raw == null) return null;
    final text = '$raw'.trim();
    if (text.length >= 10) {
      final y = int.tryParse(text.substring(0, 4));
      final m = int.tryParse(text.substring(5, 7));
      final d = int.tryParse(text.substring(8, 10));
      if (y != null && m != null && d != null) {
        return DateTime(y, m, d);
      }
    }
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
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
      final cabinetId = _cabinetId();
      final userId = _userId();
      if (cabinetId == null || userId == null) {
        isSearching = false;
        searchError = 'error';
        searchResults = [];
        notifyListeners();
        return;
      }
      isSearching = true;
      searchError = null;
      notifyListeners();
      try {
        searchResults = await _patientService.searchPatients(query: query, cabinetId: cabinetId, userId: userId);
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
