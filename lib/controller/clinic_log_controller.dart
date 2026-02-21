import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';
import '../services/cabinet_service.dart';

enum ClinicLogFilterMode { date, period }

class ClinicLogController extends ChangeNotifier {
  ClinicLogController({CabinetService? cabinetService})
      : _cabinetService = cabinetService ?? CabinetService() {
    final today = DateTime.now();
    selectedDate = DateTime(today.year, today.month, today.day);
    periodStart = selectedDate;
    periodEnd = selectedDate;
  }

  final CabinetService _cabinetService;

  bool loading = false;
  String? error;
  List<Map<String, dynamic>> logs = <Map<String, dynamic>>[];
  ClinicLogFilterMode filterMode = ClinicLogFilterMode.date;
  late DateTime selectedDate;
  DateTime? periodStart;
  DateTime? periodEnd;

  int? get _cabinetId {
    final raw = AuthController.globalClinic?['id_cabinet'];
    if (raw is num) return raw.toInt();
    return int.tryParse('$raw');
  }

  int? get _userId => AuthController.globalUserId;

  String formatDate(DateTime? date) {
    if (date == null) return '';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void setFilterMode(ClinicLogFilterMode mode) {
    if (filterMode == mode) return;
    filterMode = mode;
    notifyListeners();
  }

  void setSelectedDate(DateTime value) {
    selectedDate = DateTime(value.year, value.month, value.day);
    notifyListeners();
  }

  void setPeriodStart(DateTime value) {
    periodStart = DateTime(value.year, value.month, value.day);
    if (periodEnd != null && periodEnd!.isBefore(periodStart!)) {
      periodEnd = periodStart;
    }
    notifyListeners();
  }

  void setPeriodEnd(DateTime value) {
    periodEnd = DateTime(value.year, value.month, value.day);
    notifyListeners();
  }

  Future<void> refresh() async {
    final cabinetId = _cabinetId;
    final userId = _userId;
    if (cabinetId == null || userId == null) {
      logs = [];
      error = 'missing_context';
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      logs = await _cabinetService.fetchClinicLogs(
        requesterUserId: userId,
        cabinetId: cabinetId,
        mode: filterMode == ClinicLogFilterMode.date ? 'date' : 'period',
        date: filterMode == ClinicLogFilterMode.date ? formatDate(selectedDate) : null,
        from: filterMode == ClinicLogFilterMode.period ? formatDate(periodStart) : null,
        to: filterMode == ClinicLogFilterMode.period ? formatDate(periodEnd) : null,
      );
    } catch (e) {
      logs = [];
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
