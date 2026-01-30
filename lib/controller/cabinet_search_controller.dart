import 'dart:async';

import 'package:flutter/material.dart';

import '../services/cabinet_service.dart';
import 'auth_controller.dart';

class CabinetSearchController extends ChangeNotifier {
  CabinetSearchController({CabinetService? service}) : _service = service ?? CabinetService();

  final CabinetService _service;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  bool isLoading = false;
  String? errorCode;
  List<Map<String, dynamic>> results = [];
  int? submittingId;

  void init() {
    search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = value.trim();
      isLoading = true;
      errorCode = null;
      notifyListeners();
      try {
        results = await _service.searchCabinets(query);
      } catch (_) {
        errorCode = 'network';
      } finally {
        isLoading = false;
        notifyListeners();
      }
    });
  }

  String? cabinetImageUrl(String photoFile) => _service.cabinetPhotoUrl(photoFile);

  Future<CabinetAssignResult> assignCabinet(int cabinetId) async {
    final userId = AuthController.globalUserId;
    if (userId == null) {
      errorCode = 'session';
      notifyListeners();
      return CabinetAssignResult.failed;
    }

    submittingId = cabinetId;
    notifyListeners();
    final result = await _service.assignCabinet(userId: userId, cabinetId: cabinetId);
    submittingId = null;
    notifyListeners();
    return result;
  }
}
