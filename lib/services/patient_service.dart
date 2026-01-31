import 'dart:convert';

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
}
