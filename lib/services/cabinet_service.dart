import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/network/api_request_exception.dart';
import '../controller/auth_controller.dart';

enum CabinetAssignResult { success, exists, clinicNotValidated, failed, network }

enum CabinetCreateResult { success, exists, failed, network }

enum CabinetRemoveResult { success, lastAdmin, failed, network }

enum CabinetReviewResult { success, failed, network, unauthorized }

class CabinetCreateResponse {
  const CabinetCreateResponse(this.result, {this.message});

  final CabinetCreateResult result;
  final String? message;
}

class CabinetService {
  CabinetService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl => ApiConfig.resolveBaseUrl();

  String? cabinetPhotoUrl(String photoFile) {
    if (photoFile.isEmpty) return null;
    return '$_baseUrl/IMAGES/CABINET/$photoFile';
  }

  Future<List<Map<String, dynamic>>> fetchCabinetsForUser(int userId) async {
    final uri = Uri.parse('$_baseUrl/cabinet/by-user/$userId');
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw _httpFailureFrom(response, fallbackCode: 'request_failed');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (error) {
      if (error is ApiRequestException) rethrow;
      throw ApiRequestException(code: _transportFailureCode(error), message: error.toString());
    }
  }

  Future<List<Map<String, dynamic>>> searchCabinets(String query) async {
    final uri = Uri.parse('$_baseUrl/cabinet/search?q=${Uri.encodeQueryComponent(query)}');
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw _httpFailureFrom(response, fallbackCode: 'request_failed');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (error) {
      if (error is ApiRequestException) rethrow;
      throw ApiRequestException(code: _transportFailureCode(error), message: error.toString());
    }
  }

  Future<void> ensureCabinetDatabaseReady(int cabinetId) async {
    final uri = Uri.parse('$_baseUrl/cabinet/$cabinetId/db-ready');
    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) return;
      if (response.statusCode == 404) {
        throw const ApiRequestException(code: 'db_not_found', statusCode: 404);
      }
      throw _httpFailureFrom(response, fallbackCode: 'request_failed');
    } catch (error) {
      if (error is ApiRequestException) rethrow;
      throw ApiRequestException(code: _transportFailureCode(error), message: error.toString());
    }
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
        body: jsonEncode({'id_user': userId, 'id_cabinet': cabinetId, 'type_access': typeAccess, 'etat': etat}),
      );
      if (response.statusCode == 201) return CabinetAssignResult.success;
      if (response.statusCode == 409) return CabinetAssignResult.exists;
      if (response.statusCode == 403) return CabinetAssignResult.clinicNotValidated;
      return CabinetAssignResult.failed;
    } catch (_) {
      return CabinetAssignResult.network;
    }
  }

  Future<CabinetCreateResponse> createCabinet({
    required String name,
    required String specialty,
    required String address,
    required String phone,
    int? nationalitePatientDefaut,
    required String defaultCurrency,
    String? photoBase64,
    String? photoExtension,
  }) async {
    final userId = AuthController.globalUserId;
    final uri = Uri.parse('$_baseUrl/cabinet');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_user': userId,
          'nom_cabinet': name,
          'specialite_cabinet': specialty,
          'adresse_cabinet': address,
          'phone': phone,
          'nationalite_patient_defaut': nationalitePatientDefaut,
          'default_currency': defaultCurrency,
          if (photoBase64 != null && photoBase64.isNotEmpty) 'photo_base64': photoBase64,
          if (photoExtension != null && photoExtension.isNotEmpty) 'photo_ext': photoExtension,
        }),
      );
      // Keep backend response visible while stabilizing create-cabinet flow.
      // ignore: avoid_print
      print('Create cabinet response: ${response.statusCode} ${response.body}');
      String? message;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] != null) {
          message = decoded['error'].toString();
        }
      } catch (_) {}

      if (response.statusCode == 201) {
        return const CabinetCreateResponse(CabinetCreateResult.success);
      }
      if (response.statusCode == 409) {
        return CabinetCreateResponse(CabinetCreateResult.exists, message: message);
      }
      return CabinetCreateResponse(CabinetCreateResult.failed, message: message);
    } catch (_) {
      return const CabinetCreateResponse(CabinetCreateResult.network);
    }
  }

  Future<CabinetRemoveResult> removeCabinet({required int userId, required int cabinetId}) async {
    final uri = Uri.parse('$_baseUrl/cabinet/unassign');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_user': userId, 'id_cabinet': cabinetId}),
      );
      if (response.statusCode == 200) return CabinetRemoveResult.success;
      if (response.statusCode == 409) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['code'] == 'LAST_ADMIN') {
            return CabinetRemoveResult.lastAdmin;
          }
        } catch (_) {}
      }
      return CabinetRemoveResult.failed;
    } catch (_) {
      return CabinetRemoveResult.network;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPendingCabinetsForPlatformAdmin({
    required int adminUserId,
  }) async {
    final uri = Uri.parse('$_baseUrl/cabinet/pending-platform/$adminUserId');
    final response = await _client.get(uri);
    if (response.statusCode == 403) {
      throw Exception('unauthorized');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to load pending clinics');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPlatformCabinets({
    required int adminUserId,
    required String state,
    String query = '',
  }) async {
    final normalizedState = state.trim().isEmpty ? 'pending' : state.trim().toLowerCase();
    final uri = Uri.parse(
      '$_baseUrl/cabinet/platform-list/$adminUserId'
      '?state=${Uri.encodeQueryComponent(normalizedState)}'
      '&q=${Uri.encodeQueryComponent(query)}',
    );
    final response = await _client.get(uri);
    if (response.statusCode == 403) {
      throw Exception('unauthorized');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to load clinics');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<CabinetReviewResult> approveCabinet({
    required int adminUserId,
    required int cabinetId,
  }) async {
    return _reviewCabinet(
      path: '/cabinet/validate',
      payload: {'id_admin': adminUserId, 'id_cabinet': cabinetId},
    );
  }

  Future<CabinetReviewResult> rejectCabinet({
    required int adminUserId,
    required int cabinetId,
  }) async {
    return _reviewCabinet(
      path: '/cabinet/reject-clinic',
      payload: {'id_admin': adminUserId, 'id_cabinet': cabinetId},
    );
  }

  Future<CabinetReviewResult> _reviewCabinet({
    required String path,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) return CabinetReviewResult.success;
      if (response.statusCode == 403) return CabinetReviewResult.unauthorized;
      return CabinetReviewResult.failed;
    } catch (_) {
      return CabinetReviewResult.network;
    }
  }

  ApiRequestException _httpFailureFrom(http.Response response, {required String fallbackCode}) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final rawCode = decoded['code']?.toString().trim().toLowerCase();
        if (rawCode != null && rawCode.isNotEmpty) {
          return ApiRequestException(
            code: _mapServerCode(rawCode),
            statusCode: response.statusCode,
            message: decoded['error']?.toString(),
          );
        }
      }
    } catch (_) {}
    if (response.statusCode == 401 || response.statusCode == 403) {
      return ApiRequestException(code: 'unauthorized', statusCode: response.statusCode);
    }
    return ApiRequestException(code: fallbackCode, statusCode: response.statusCode);
  }

  String _mapServerCode(String code) {
    switch (code) {
      case 'db_not_found':
        return 'db_not_found';
      case 'db_unavailable':
        return 'db_unavailable';
      default:
        return 'request_failed';
    }
  }

  String _transportFailureCode(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('network is unreachable') ||
        text.contains('no route to host') ||
        text.contains('failed host lookup')) {
      return 'internet_unavailable';
    }
    if (text.contains('connection refused') ||
        text.contains('connection reset') ||
        text.contains('connection closed') ||
        text.contains('timed out')) {
      return 'server_unreachable';
    }
    return 'network';
  }
}
