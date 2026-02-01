import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';

class PatientService {
  PatientService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl => ApiConfig.resolveBaseUrl();

  Future<List<Map<String, dynamic>>> fetchPatients() async {
    final uri = Uri.parse('$_baseUrl/patients');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load patients');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    final uri = Uri.parse('$_baseUrl/patients/search?q=${Uri.encodeQueryComponent(query)}');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to search patients');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<int> fetchPatientCount() async {
    final patients = await fetchPatients();
    return patients.length;
  }

  Future<void> createPatient(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/patients');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    debugPrint('Create patient response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 201) {
      throw Exception('Failed to create patient');
    }
  }

  Future<void> updatePatient(int id, Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/patients/$id');
    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    debugPrint('Update patient response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to update patient');
    }
  }

  String? patientPhotoUrl(String photoFile) {
    if (photoFile.isEmpty) return null;
    return '$_baseUrl/IMAGES/PATIENT/$photoFile';
  }
}
