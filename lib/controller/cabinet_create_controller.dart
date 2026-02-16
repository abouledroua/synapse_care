import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/cabinet_service.dart';

class CabinetCreateController extends ChangeNotifier {
  CabinetCreateController({CabinetService? service}) : _service = service ?? CabinetService();

  final CabinetService _service;

  bool submitting = false;
  bool nameAlreadyExists = false;

  Future<CabinetCreateResponse> submit({
    required String name,
    required String specialty,
    required String address,
    required String phone,
    required int? nationalitePatientDefaut,
    required String defaultCurrency,
    Uint8List? photoBytes,
    String? photoExtension,
  }) async {
    if (submitting) {
      return const CabinetCreateResponse(CabinetCreateResult.failed);
    }
    submitting = true;
    nameAlreadyExists = false;
    notifyListeners();
    try {
      final photoBase64 = photoBytes == null ? null : base64Encode(photoBytes);
      final response = await _service.createCabinet(
        name: name,
        specialty: specialty,
        address: address,
        phone: phone,
        nationalitePatientDefaut: nationalitePatientDefaut,
        defaultCurrency: defaultCurrency,
        photoBase64: photoBase64,
        photoExtension: photoExtension,
      );
      if (response.result == CabinetCreateResult.exists) {
        nameAlreadyExists = true;
      }
      return response;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  void clearNameError() {
    if (!nameAlreadyExists) return;
    nameAlreadyExists = false;
    notifyListeners();
  }
}
