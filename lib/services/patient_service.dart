import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';

class PatientService {
  PatientService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl => ApiConfig.resolveBaseUrl();

  Future<List<Map<String, dynamic>>> fetchPatients({
    required int cabinetId,
    required int userId,
  }) async {
    final uri = Uri.parse('$_baseUrl/patients?id_cabinet=$cabinetId&id_user=$userId');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load patients');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<List<Map<String, dynamic>>> searchPatients({
    required String query,
    required int cabinetId,
    required int userId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/patients/search?q=${Uri.encodeQueryComponent(query)}&id_cabinet=$cabinetId&id_user=$userId',
    );
    final response = await _client.get(uri);
    debugPrint('Search patients response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to search patients');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<int> fetchPatientCount({required int cabinetId, required int userId}) async {
    final patients = await fetchPatients(cabinetId: cabinetId, userId: userId);
    return patients.length;
  }

  Future<void> deletePatient(int id, {required int cabinetId, required int userId}) async {
    final uri = Uri.parse('$_baseUrl/patients/$id?id_cabinet=$cabinetId&id_user=$userId');
    final response = await _client.delete(uri);
    debugPrint('Delete patient response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete patient');
    }
  }

  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/patients');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    debugPrint('Create patient response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 409) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          return {'status': 409, ...Map<String, dynamic>.from(decoded)};
        }
      } catch (_) {}
      return {'status': 409};
    }
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create patient');
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return {'status': response.statusCode, ...Map<String, dynamic>.from(decoded)};
      }
    } catch (_) {}
    return {'status': response.statusCode};
  }

  Future<Map<String, dynamic>> updatePatient(int id, Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/patients/$id');
    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    debugPrint('Update patient response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 409) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          return {'status': 409, ...Map<String, dynamic>.from(decoded)};
        }
      } catch (_) {}
      return {'status': 409};
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to update patient');
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return {'status': response.statusCode, ...Map<String, dynamic>.from(decoded)};
      }
    } catch (_) {}
    return {'status': response.statusCode};
  }

  Future<void> linkPatient({required int cabinetId, required int patientId, required int userId}) async {
    final uri = Uri.parse('$_baseUrl/patients/link');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_cabinet': cabinetId, 'id_patient': patientId, 'id_user': userId}),
    );
    debugPrint('Link patient response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 201) {
      throw Exception('Failed to link patient');
    }
  }

  Future<Map<String, dynamic>> checkExistingByIdentity({
    required int cabinetId,
    required int userId,
    required int nationality,
    String nin = '',
    String nss = '',
  }) async {
    final uri = Uri.parse('$_baseUrl/patients/check-existing');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_cabinet': cabinetId,
        'id_user': userId,
        'nationality': nationality,
        'nin': nin,
        'nss': nss,
      }),
    );
    debugPrint('Check existing patient response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to check patient existence');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return {'exists': false};
  }

  String? patientPhotoUrl(String photoFile) {
    if (photoFile.isEmpty) return null;
    return '$_baseUrl/IMAGES/PATIENT/$photoFile';
  }
}
