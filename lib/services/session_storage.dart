import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  const SessionStorage._();

  static const _keyUserId = 'session_user_id';
  static const _keyUser = 'session_user';
  static const _keyClinic = 'session_clinic';
  static const _keyLastActivity = 'session_last_activity';

  static Future<void> save({
    required int? userId,
    required Map<String, dynamic>? user,
    required Map<String, dynamic>? clinic,
    required DateTime? lastActivity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null || user == null) {
      await clear();
      return;
    }
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUser, jsonEncode(user));
    if (clinic != null) {
      await prefs.setString(_keyClinic, jsonEncode(clinic));
    } else {
      await prefs.remove(_keyClinic);
    }
    if (lastActivity != null) {
      await prefs.setInt(_keyLastActivity, lastActivity.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_keyLastActivity);
    }
  }

  static Future<SessionData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId);
    final userJson = prefs.getString(_keyUser);
    if (userId == null || userJson == null) return null;
    final clinicJson = prefs.getString(_keyClinic);
    final lastActivityMillis = prefs.getInt(_keyLastActivity);

    Map<String, dynamic>? parseMap(String? value) {
      if (value == null) return null;
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
      return null;
    }

    return SessionData(
      userId: userId,
      user: parseMap(userJson),
      clinic: parseMap(clinicJson),
      lastActivity: lastActivityMillis != null ? DateTime.fromMillisecondsSinceEpoch(lastActivityMillis) : null,
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUser);
    await prefs.remove(_keyClinic);
    await prefs.remove(_keyLastActivity);
  }
}

class SessionData {
  const SessionData({
    required this.userId,
    required this.user,
    required this.clinic,
    required this.lastActivity,
  });

  final int userId;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? clinic;
  final DateTime? lastActivity;
}
