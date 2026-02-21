import 'package:flutter/material.dart';

import 'auth_controller.dart';
import '../services/cabinet_service.dart';

class SettingsAppointmentController extends ChangeNotifier {
  SettingsAppointmentController({CabinetService? cabinetService}) : _cabinetService = cabinetService ?? CabinetService();

  final CabinetService _cabinetService;
  bool isLoading = true;
  bool isSaving = false;
  final Map<int, bool> _dayEnabled = {
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
    6: true,
    7: true,
  };

  bool isDayEnabled(int day) => _dayEnabled[day] ?? false;

  int? get _cabinetId {
    final raw = AuthController.globalClinic?['id_cabinet'];
    return raw is num ? raw.toInt() : int.tryParse('$raw');
  }

  int? get _userId => AuthController.globalUserId;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final cabinetId = _cabinetId;
    final userId = _userId;
    if (cabinetId != null && userId != null) {
      try {
        final remote = await _cabinetService.fetchCabinetOpenDays(
          requesterUserId: userId,
          cabinetId: cabinetId,
        );
        if (remote.isNotEmpty) {
          for (final day in _dayEnabled.keys) {
            _dayEnabled[day] = remote[day] ?? true;
          }
        }
      } catch (_) {
        // Keep defaults when request fails.
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> setDayEnabled(int day, bool enabled) async {
    if (!_dayEnabled.containsKey(day)) return;
    if (_dayEnabled[day] == enabled) return;
    final cabinetId = _cabinetId;
    final userId = _userId;
    if (cabinetId == null || userId == null) return;

    final previous = _dayEnabled[day] ?? true;
    _dayEnabled[day] = enabled;
    isSaving = true;
    notifyListeners();
    final result = await _cabinetService.updateCabinetOpenDay(
      requesterUserId: userId,
      cabinetId: cabinetId,
      dayOfWeek: day,
      isOpen: enabled,
    );
    if (result != CabinetOpenDayUpdateResult.success) {
      _dayEnabled[day] = previous;
    }
    isSaving = false;
    notifyListeners();
  }
}
