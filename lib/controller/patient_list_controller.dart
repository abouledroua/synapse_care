import 'dart:async';

import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    listController.dispose();
    listFocusNode.dispose();
    super.dispose();
  }

  Future<void> loadPatients() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      patients = await _service.fetchPatients();
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
    loading = true;
    error = null;
    notifyListeners();
    try {
      patients = await _service.searchPatients(query);
    } catch (_) {
      error = 'network';
      patients = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
