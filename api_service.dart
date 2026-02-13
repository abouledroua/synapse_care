import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Adjust this based on your environment (Emulator vs Real Device)
  static const String _baseUrl = 'http://10.0.2.2:3001';

  /// Login to the application
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data; // Returns user object
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } on SocketException {
      throw Exception('Could not connect to the server. Check your internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up a new doctor
  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/auth/signup');

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(userData));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Signup failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
