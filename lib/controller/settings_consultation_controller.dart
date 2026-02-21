import 'package:flutter/material.dart';

import 'auth_controller.dart';
import '../services/cabinet_service.dart';

class SettingsConsultationController extends ChangeNotifier {
  SettingsConsultationController({CabinetService? cabinetService})
      : _cabinetService = cabinetService ?? CabinetService();

  final CabinetService _cabinetService;

  bool isLoading = true;
  bool isSaving = false;
  final Map<String, bool> _flags = <String, bool>{
    'certificat_medical_enabled': true,
    'bilans_enabled': true,
    'lettre_orientation_enabled': true,
    'arret_travail_enabled': true,
    'rapports_medicaux_enabled': true,
  };
  String gestOrdonnance = 'selection_medicaments';

  int? get _cabinetId {
    final raw = AuthController.globalClinic?['id_cabinet'];
    return raw is num ? raw.toInt() : int.tryParse('$raw');
  }

  int? get _userId => AuthController.globalUserId;

  bool isEnabled(String key) => _flags[key] ?? false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final cabinetId = _cabinetId;
    final userId = _userId;
    if (cabinetId != null && userId != null) {
      try {
        final remote = await _cabinetService.fetchConsultationParams(
          requesterUserId: userId,
          cabinetId: cabinetId,
        );
        for (final key in _flags.keys) {
          final raw = remote[key];
          _flags[key] = raw == true || '$raw'.toLowerCase() == 'true';
        }
        final rawGest = '${remote['gest_ordonnance'] ?? ''}'.trim();
        if (rawGest == 'selection_medicaments' || rawGest == 'saisie_prescription') {
          gestOrdonnance = rawGest;
        }
      } catch (_) {
        // Keep defaults.
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> setEnabled(String key, bool enabled) async {
    if (!_flags.containsKey(key)) return;
    final cabinetId = _cabinetId;
    final userId = _userId;
    if (cabinetId == null || userId == null) return;
    final previous = _flags[key] ?? true;
    _flags[key] = enabled;
    isSaving = true;
    notifyListeners();
    final result = await _cabinetService.updateConsultationParam(
      requesterUserId: userId,
      cabinetId: cabinetId,
      key: key,
      enabled: enabled,
    );
    if (result != ConsultationParamUpdateResult.success) {
      _flags[key] = previous;
    }
    isSaving = false;
    notifyListeners();
  }

  Future<void> setGestOrdonnance(String value) async {
    if (value != 'selection_medicaments' && value != 'saisie_prescription') return;
    final cabinetId = _cabinetId;
    final userId = _userId;
    if (cabinetId == null || userId == null) return;
    final previous = gestOrdonnance;
    gestOrdonnance = value;
    isSaving = true;
    notifyListeners();
    final result = await _cabinetService.updateConsultationParam(
      requesterUserId: userId,
      cabinetId: cabinetId,
      key: 'gest_ordonnance',
      value: value,
    );
    if (result != ConsultationParamUpdateResult.success) {
      gestOrdonnance = previous;
    }
    isSaving = false;
    notifyListeners();
  }
}
