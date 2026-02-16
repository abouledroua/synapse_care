import 'package:flutter/material.dart';

import '../services/appointment_service.dart';
import 'auth_controller.dart';

enum AppointmentFilterMode { date, period, all }

class AppointmentListController extends ChangeNotifier {
  AppointmentListController({AppointmentService? service})
      : _service = service ?? AppointmentService() {
    final today = DateTime.now();
    selectedDate = DateTime(today.year, today.month, today.day);
  }

  final AppointmentService _service;
  final TextEditingController searchController = TextEditingController();
  final List<Map<String, dynamic>> appointments = <Map<String, dynamic>>[];

  bool loading = false;
  AppointmentFilterMode filterMode = AppointmentFilterMode.date;
  DateTime? selectedDate;
  DateTime? periodStart;
  DateTime? periodEnd;

  int? get cabinetId {
    final raw = AuthController.globalClinic?['id_cabinet'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  int? get userId => AuthController.globalUserId;

  List<Map<String, dynamic>> get filteredAppointments {
    final query = searchController.text.trim().toLowerCase();
    return appointments.where((item) {
      final date = _dateOnly(appointmentDate(item));
      if (filterMode == AppointmentFilterMode.date && selectedDate != null) {
        final selected = _dateOnly(selectedDate);
        if (date == null || selected == null || !_isSameDay(date, selected)) return false;
      }
      if (filterMode == AppointmentFilterMode.period && (periodStart != null || periodEnd != null)) {
        if (date == null) return false;
        final start = _dateOnly(periodStart);
        final end = _dateOnly(periodEnd);
        if (start != null && date.isBefore(start)) return false;
        if (end != null && date.isAfter(end)) return false;
      }
      if (query.isEmpty) return true;
      final haystack = [
        '${item['num_rdv'] ?? ''}',
        '${item['motif_rdv'] ?? ''}',
        '${item['nom_patient'] ?? ''}',
        '${item['prenom_patient'] ?? ''}',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  DateTime? appointmentDate(Map<String, dynamic> item) {
    final raw = item['date_rdv'] ?? item['date'] ?? item['date_rendez_vous'];
    if (raw == null) return null;
    if (raw is DateTime) return DateTime(raw.year, raw.month, raw.day);
    final text = raw.toString().trim();
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

  String formatDate(DateTime? date) {
    if (date == null) return '--';
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  Future<void> refresh() async {
    if (cabinetId == null || userId == null) {
      appointments.clear();
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final rows = await _service.fetchAppointments(
        cabinetId: cabinetId!,
        userId: userId!,
      );
      appointments
        ..clear()
        ..addAll(rows);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String _) => notifyListeners();

  void clearSearch() {
    searchController.clear();
    notifyListeners();
  }

  void setFilterMode(AppointmentFilterMode mode) {
    filterMode = mode;
    if (filterMode == AppointmentFilterMode.date && selectedDate == null) {
      final today = DateTime.now();
      selectedDate = DateTime(today.year, today.month, today.day);
    }
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    filterMode = AppointmentFilterMode.date;
    selectedDate = date;
    notifyListeners();
  }

  void setPeriodStart(DateTime date) {
    filterMode = AppointmentFilterMode.period;
    periodStart = date;
    if (periodEnd != null && periodEnd!.isBefore(date)) {
      periodEnd = date;
    }
    notifyListeners();
  }

  void setPeriodEnd(DateTime date) {
    filterMode = AppointmentFilterMode.period;
    periodEnd = date;
    if (periodStart != null && periodStart!.isAfter(date)) {
      periodStart = date;
    }
    notifyListeners();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime? _dateOnly(DateTime? value) {
    if (value == null) return null;
    return DateTime(value.year, value.month, value.day);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
