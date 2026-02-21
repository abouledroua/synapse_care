import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/network/api_request_exception.dart';
import '../controller/auth_controller.dart';

enum CabinetAssignResult { success, exists, clinicNotValidated, failed, network }

enum CabinetCreateResult { success, exists, failed, network }

enum CabinetRemoveResult { success, lastAdmin, failed, network }

enum CabinetReviewResult { success, failed, network, unauthorized }
enum CabinetMemberActionResult { success, failed, network, unauthorized, lastAdmin }
enum CabinetOpenDayUpdateResult { success, failed, network, unauthorized }
enum ConsultationParamUpdateResult { success, failed, network, unauthorized }

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
      // ignore: avoid_print
      print('Assign cabinet response: ${response.statusCode} ${response.body}');
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

  Future<(bool isCurrentUserAdmin, List<Map<String, dynamic>> items)> fetchCabinetUsers({
    required int requesterUserId,
    required int cabinetId,
    required String state,
    String query = '',
  }) async {
    final normalizedState = state.trim().isEmpty ? 'all' : state.trim().toLowerCase();
    final uri = Uri.parse(
      '$_baseUrl/cabinet/users'
      '?id_cabinet=$cabinetId'
      '&id_user=$requesterUserId'
      '&state=${Uri.encodeQueryComponent(normalizedState)}'
      '&q=${Uri.encodeQueryComponent(query)}',
    );
    final response = await _client.get(uri);
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('unauthorized');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to load clinic users');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      return (false, const <Map<String, dynamic>>[]);
    }
    final rawItems = decoded['items'];
    final items = rawItems is List
        ? rawItems.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
        : const <Map<String, dynamic>>[];
    final isCurrentUserAdmin = decoded['current_user_is_admin'] == true;
    return (isCurrentUserAdmin, items);
  }

  Future<CabinetMemberActionResult> approveCabinetUser({
    required int adminUserId,
    required int targetUserId,
    required int cabinetId,
  }) async {
    return _reviewCabinetMember(
      path: '/cabinet/approve',
      payload: {'id_admin': adminUserId, 'id_user': targetUserId, 'id_cabinet': cabinetId},
    );
  }

  Future<CabinetMemberActionResult> rejectCabinetUser({
    required int adminUserId,
    required int targetUserId,
    required int cabinetId,
  }) async {
    return _reviewCabinetMember(
      path: '/cabinet/reject',
      payload: {'id_admin': adminUserId, 'id_user': targetUserId, 'id_cabinet': cabinetId},
    );
  }

  Future<CabinetMemberActionResult> grantCabinetAdmin({
    required int adminUserId,
    required int targetUserId,
    required int cabinetId,
  }) async {
    return _reviewCabinetMember(
      path: '/cabinet/admin/grant',
      payload: {'id_admin': adminUserId, 'id_user': targetUserId, 'id_cabinet': cabinetId},
    );
  }

  Future<CabinetMemberActionResult> revokeCabinetAdmin({
    required int adminUserId,
    required int targetUserId,
    required int cabinetId,
  }) async {
    return _reviewCabinetMember(
      path: '/cabinet/admin/revoke',
      payload: {'id_admin': adminUserId, 'id_user': targetUserId, 'id_cabinet': cabinetId},
    );
  }

  Future<CabinetMemberActionResult> _reviewCabinetMember({
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
      if (response.statusCode == 200) return CabinetMemberActionResult.success;
      if (response.statusCode == 403) return CabinetMemberActionResult.unauthorized;
      if (response.statusCode == 409) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['code'] == 'LAST_ADMIN') {
            return CabinetMemberActionResult.lastAdmin;
          }
        } catch (_) {}
      }
      return CabinetMemberActionResult.failed;
    } catch (_) {
      return CabinetMemberActionResult.network;
    }
  }

  Future<Map<int, bool>> fetchCabinetOpenDays({
    required int requesterUserId,
    required int cabinetId,
  }) async {
    final uri = Uri.parse('$_baseUrl/cabinet/open-days?id_cabinet=$cabinetId&id_user=$requesterUserId');
    try {
      final response = await _client.get(uri);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ApiRequestException(code: 'unauthorized', statusCode: 403);
      }
      if (response.statusCode != 200) {
        throw _httpFailureFrom(response, fallbackCode: 'request_failed');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return {};
      final map = <int, bool>{};
      for (final raw in decoded) {
        if (raw is! Map) continue;
        final item = Map<String, dynamic>.from(raw);
        final day = item['day_of_week'] is num
            ? (item['day_of_week'] as num).toInt()
            : int.tryParse('${item['day_of_week']}');
        if (day == null || day < 1 || day > 7) continue;
        final isOpen = item['is_open'] == true || '${item['is_open']}'.toLowerCase() == 'true';
        map[day] = isOpen;
      }
      return map;
    } catch (error) {
      if (error is ApiRequestException) rethrow;
      throw ApiRequestException(code: _transportFailureCode(error), message: error.toString());
    }
  }

  Future<CabinetOpenDayUpdateResult> updateCabinetOpenDay({
    required int requesterUserId,
    required int cabinetId,
    required int dayOfWeek,
    required bool isOpen,
  }) async {
    final uri = Uri.parse('$_baseUrl/cabinet/open-days/update');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_cabinet': cabinetId,
          'id_user': requesterUserId,
          'day_of_week': dayOfWeek,
          'is_open': isOpen,
        }),
      );
      if (response.statusCode == 200) return CabinetOpenDayUpdateResult.success;
      if (response.statusCode == 401 || response.statusCode == 403) {
        return CabinetOpenDayUpdateResult.unauthorized;
      }
      return CabinetOpenDayUpdateResult.failed;
    } catch (_) {
      return CabinetOpenDayUpdateResult.network;
    }
  }

  Future<bool> isClinicAdmin({
    required int requesterUserId,
    required int cabinetId,
  }) async {
    final uri = Uri.parse('$_baseUrl/cabinet/is-admin?id_cabinet=$cabinetId&id_user=$requesterUserId');
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return false;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return false;
      return decoded['is_admin'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchClinicLogs({
    required int requesterUserId,
    required int cabinetId,
    required String mode,
    String? date,
    String? from,
    String? to,
  }) async {
    final query = <String, String>{
      'id_cabinet': '$cabinetId',
      'id_user': '$requesterUserId',
      'mode': mode,
      if (date != null && date.isNotEmpty) 'date': date,
      if (from != null && from.isNotEmpty) 'from': from,
      if (to != null && to.isNotEmpty) 'to': to,
    };
    final uri = Uri.parse('$_baseUrl/cabinet/logs').replace(queryParameters: query);
    final response = await _client.get(uri);
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('unauthorized');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to load logs');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, dynamic>> fetchConsultationParams({
    required int requesterUserId,
    required int cabinetId,
  }) async {
    final uri = Uri.parse('$_baseUrl/cabinet/consultation-params?id_cabinet=$cabinetId&id_user=$requesterUserId');
    try {
      final response = await _client.get(uri);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ApiRequestException(code: 'unauthorized', statusCode: 403);
      }
      if (response.statusCode != 200) {
        throw _httpFailureFrom(response, fallbackCode: 'request_failed');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return {};
      final map = <String, dynamic>{};
      for (final entry in decoded.entries) {
        final key = '${entry.key}';
        map[key] = entry.value;
      }
      return map;
    } catch (error) {
      if (error is ApiRequestException) rethrow;
      throw ApiRequestException(code: _transportFailureCode(error), message: error.toString());
    }
  }

  Future<ConsultationParamUpdateResult> updateConsultationParam({
    required int requesterUserId,
    required int cabinetId,
    required String key,
    bool? enabled,
    String? value,
  }) async {
    final uri = Uri.parse('$_baseUrl/cabinet/consultation-params/update');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_cabinet': cabinetId,
          'id_user': requesterUserId,
          'key': key,
          if (enabled != null) 'enabled': enabled,
          if (value != null) 'value': value,
        }),
      );
      if (response.statusCode == 200) return ConsultationParamUpdateResult.success;
      if (response.statusCode == 401 || response.statusCode == 403) {
        return ConsultationParamUpdateResult.unauthorized;
      }
      return ConsultationParamUpdateResult.failed;
    } catch (_) {
      return ConsultationParamUpdateResult.network;
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
