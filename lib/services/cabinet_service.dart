import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';

enum CabinetAssignResult { success, exists, failed, network }

class CabinetService {
  CabinetService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl => ApiConfig.resolveBaseUrl();

  String? cabinetPhotoUrl(String photoFile) {
    if (photoFile.isEmpty) return null;
    return '$_baseUrl/IMAGES/Cabinets/$photoFile';
  }

  Future<List<Map<String, dynamic>>> fetchCabinetsForUser(int userId) async {
    final uri = Uri.parse('$_baseUrl/cabinet/by-user/$userId');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load cabinets');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<List<Map<String, dynamic>>> searchCabinets(String query) async {
    final uri = Uri.parse('$_baseUrl/cabinet/search?q=${Uri.encodeQueryComponent(query)}');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to search cabinets');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<CabinetAssignResult> assignCabinet({
    required int userId,
    required int cabinetId,
    int typeAccess = 1,
    int etat = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/cabinet/assign');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_user': userId,
          'id_cabinet': cabinetId,
          'type_access': typeAccess,
          'etat': etat,
        }),
      );
      if (response.statusCode == 201) return CabinetAssignResult.success;
      if (response.statusCode == 409) return CabinetAssignResult.exists;
      return CabinetAssignResult.failed;
    } catch (_) {
      return CabinetAssignResult.network;
    }
  }
}
