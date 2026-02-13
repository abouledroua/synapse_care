import 'package:flutter/material.dart';

import '../services/cabinet_service.dart';
import 'auth_controller.dart';

class CabinetSelectController extends ChangeNotifier {
  CabinetSelectController({CabinetService? service}) : _service = service ?? CabinetService();

  final CabinetService _service;
  bool isLoading = false;
  String? errorCode;
  List<Map<String, dynamic>> cabinets = [];

  Future<void> load() async {
    final userId = AuthController.globalUserId;
    if (userId == null) {
      cabinets = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    errorCode = null;
    notifyListeners();
    try {
      cabinets = await _service.fetchCabinetsForUser(userId);
    } catch (_) {
      errorCode = 'network';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String? cabinetImageUrl(String photoFile) => _service.cabinetPhotoUrl(photoFile);

  void selectCabinet(Map<String, dynamic> item) {
    AuthController.globalClinic = {
      'id_cabinet': item['id_cabinet'],
      'nom_cabinet': item['nom_cabinet'],
      'specialite_cabinet': item['specialite_cabinet'],
      'photo_url': item['photo_url'],
      'nationalite_patient_defaut': item['nationalite_patient_defaut'],
      'default_currency': item['default_currency'],
    };
    AuthController.persistGlobals();
  }

  Future<CabinetRemoveResult> removeCabinet(int cabinetId) async {
    final userId = AuthController.globalUserId;
    if (userId == null) return CabinetRemoveResult.failed;

    final result = await _service.removeCabinet(userId: userId, cabinetId: cabinetId);
    if (result == CabinetRemoveResult.success) {
      final currentId = AuthController.globalClinic?['id_cabinet'];
      if (currentId == cabinetId) {
        AuthController.globalClinic = null;
        AuthController.persistGlobals();
      }
      await load();
    }
    return result;
  }
}
