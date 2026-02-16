import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';

class AppointmentService {
  AppointmentService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl => ApiConfig.resolveBaseUrl();

  Future<List<Map<String, dynamic>>> fetchAppointments({
    required int cabinetId,
    required int userId,
  }) async {
    final uri = Uri.parse('$_baseUrl/rdv?id_cabinet=$cabinetId&id_user=$userId');
    final response = await _client.get(uri);
    debugPrint('Fetch appointments response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to load appointments');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> fetchActiveAppointment({
    required int cabinetId,
    required int userId,
    required int patientId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/rdv/active?id_cabinet=$cabinetId&id_user=$userId&id_patient=$patientId',
    );
    final response = await _client.get(uri);
    debugPrint('Active appointment response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to check active appointment');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map && decoded['appointment'] is Map) {
      return Map<String, dynamic>.from(decoded['appointment'] as Map);
    }
    return null;
  }

  Future<void> createAppointment(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/rdv');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    debugPrint('Create appointment response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body, 'Failed to create appointment'));
    }
  }

  Future<void> updateAppointment(int idRdv, Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/rdv/$idRdv');
    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    debugPrint('Update appointment response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body, 'Failed to update appointment'));
    }
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] != null) {
        return '${decoded['error']}';
      }
    } catch (_) {}
    return fallback;
  }
}
