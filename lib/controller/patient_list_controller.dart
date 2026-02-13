import 'dart:async';

import 'package:flutter/material.dart';

import 'auth_controller.dart';
import '../services/patient_service.dart';

class PatientListController extends ChangeNotifier {
  PatientListController({PatientService? service}) : _service = service ?? PatientService();

  final PatientService _service;
  final TextEditingController searchController = TextEditingController();
  final ScrollController listController = ScrollController();
  final FocusNode listFocusNode = FocusNode();

  Timer? _searchDebounce;
  bool loading = false;
  String? error;
  List<Map<String, dynamic>> patients = [];

  int? get cabinetId {
    final raw = AuthController.globalClinic?['id_cabinet'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  int? get userId {
    return AuthController.globalUserId;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    listController.dispose();
    listFocusNode.dispose();
    super.dispose();
  }

  Future<void> loadPatients() async {
    if (cabinetId == null || userId == null) {
      loading = false;
      error = 'no_clinic';
      patients = [];
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      patients = await _service.fetchPatients(cabinetId: cabinetId!, userId: userId!);
    } catch (_) {
      error = 'network';
      patients = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (cabinetId == null || userId == null) {
        error = 'no_clinic';
        patients = [];
        notifyListeners();
        return;
      }
      final query = searchController.text.trim();
      if (query.isEmpty) {
        loadPatients();
      } else {
        searchPatients(query);
      }
    });
  }

  void clearSearch() {
    searchController.clear();
    notifyListeners();
    loadPatients();
  }

  Future<void> searchPatients(String query) async {
    if (cabinetId == null || userId == null) {
      loading = false;
      error = 'no_clinic';
      patients = [];
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      patients = await _service.searchPatients(query: query, cabinetId: cabinetId!, userId: userId!);
    } catch (_) {
      error = 'network';
      patients = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePatient(int id) async {
    try {
      if (cabinetId == null || userId == null) return false;
      await _service.deletePatient(id, cabinetId: cabinetId!, userId: userId!);
      return true;
    } catch (_) {
      return false;
    }
  }
}
