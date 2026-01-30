import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/phone_number.dart';

import '../core/config/api_config.dart';
import '../services/session_storage.dart';

class AuthController extends ChangeNotifier {
  static int? globalUserId;
  static Map<String, dynamic>? globalUser;
  static Map<String, dynamic>? globalClinic;
  static DateTime? _globalLastActivity;
  static Timer? _globalTimer;
  static const Duration sessionTimeoutDuration = Duration(minutes: 20);
  bool obscurePassword = true;
  bool isDoctor = false;
  String? phoneError;
  String phoneNumber = '';
  bool isBusy = false;
  String password = '';
  String confirmPassword = '';
  String? passwordError;
  String? confirmPasswordError;
  String? nameError;
  String? emailError;
  String? specialtyError;
  String? loginEmailError;
  String? loginPasswordError;
  String? loginSubmitError;
  String? photoBase64;
  String? photoExtension;
  int? currentUserId;
  DateTime? _lastActivity;
  Timer? _sessionTimer;
  final Duration sessionTimeout = sessionTimeoutDuration;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  static String resolveApiBaseUrl() {
    return ApiConfig.resolveBaseUrl();
  }

  static String _resolveApiBaseUrl() => resolveApiBaseUrl();
  String apiBaseUrl = _resolveApiBaseUrl();

  @override
  void dispose() {
    _sessionTimer?.cancel();
    nameController.dispose();
    emailController.dispose();
    specialtyController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void setDoctor(bool value) {
    if (isDoctor == value) return;
    isDoctor = value;
    notifyListeners();
  }

  void _setPhoneError(String? value) {
    if (phoneError == value) return;
    phoneError = value;
    notifyListeners();
  }

  void _setNameError(String? value) {
    if (nameError == value) return;
    nameError = value;
    notifyListeners();
  }

  void _setEmailError(String? value) {
    if (emailError == value) return;
    emailError = value;
    notifyListeners();
  }

  void _setSpecialtyError(String? value) {
    if (specialtyError == value) return;
    specialtyError = value;
    notifyListeners();
  }

  void _setLoginEmailError(String? value) {
    if (loginEmailError == value) return;
    loginEmailError = value;
    notifyListeners();
  }

  void _setLoginPasswordError(String? value) {
    if (loginPasswordError == value) return;
    loginPasswordError = value;
    notifyListeners();
  }

  void setLoginSubmitError(String? value) {
    if (loginSubmitError == value) return;
    loginSubmitError = value;
    notifyListeners();
  }

  void _startSession(int userId) {
    currentUserId = userId;
    globalUserId = userId;
    _touchSession();
  }

  void _setGlobalUser(Map<String, dynamic>? data) {
    if (data == null) {
      globalUser = null;
      persistGlobals();
      return;
    }
    globalUser = Map<String, dynamic>.from(data);
    persistGlobals();
  }

  void _touchSession() {
    _lastActivity = DateTime.now();
    _globalLastActivity = _lastActivity;
    _sessionTimer?.cancel();
    _sessionTimer = Timer(sessionTimeout, _expireSessionIfIdle);
    _scheduleGlobalTimeout();
    persistGlobals();
    notifyListeners();
  }

  void _expireSessionIfIdle() {
    if (_lastActivity == null) return;
    final idleFor = DateTime.now().difference(_lastActivity!);
    if (idleFor >= sessionTimeout) {
      logout();
    } else {
      final remaining = sessionTimeout - idleFor;
      _sessionTimer?.cancel();
      _sessionTimer = Timer(remaining, _expireSessionIfIdle);
    }
  }

  void logout() {
    currentUserId = null;
    globalUserId = null;
    globalUser = null;
    globalClinic = null;
    _lastActivity = null;
    _globalLastActivity = null;
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _globalTimer?.cancel();
    _globalTimer = null;
    SessionStorage.clear();
    notifyListeners();
  }

  void markActivity() {
    if (globalUserId == null) return;
    _touchSession();
  }

  void setPhoto(Uint8List bytes, String extension) {
    photoBase64 = base64Encode(bytes);
    photoExtension = extension;
    notifyListeners();
  }

  void clearPhoto() {
    if (photoBase64 == null && photoExtension == null) return;
    photoBase64 = null;
    photoExtension = null;
    notifyListeners();
  }

  void setBusy(bool value) {
    if (isBusy == value) return;
    isBusy = value;
    notifyListeners();
  }

  bool validateName(String value, {required String emptyMessage}) {
    if (value.trim().isEmpty) {
      _setNameError(emptyMessage);
      return false;
    }
    _setNameError(null);
    return true;
  }

  bool validateEmail(String value, {required String emptyMessage, required String invalidMessage}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _setEmailError(emptyMessage);
      return false;
    }
    final isValid = RegExp(r'^[^@\s-]+@[^@\s-]+\.[^@\s-]+$').hasMatch(trimmed);
    if (!isValid) {
      _setEmailError(invalidMessage);
      return false;
    }
    _setEmailError(null);
    return true;
  }

  bool validateLoginEmail(String value, {required String emptyMessage, required String invalidMessage}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _setLoginEmailError(emptyMessage);
      return false;
    }
    final isValid = RegExp(r'^[^@\s-]+@[^@\s-]+\.[^@\s-]+$').hasMatch(trimmed);
    if (!isValid) {
      _setLoginEmailError(invalidMessage);
      return false;
    }
    _setLoginEmailError(null);
    return true;
  }

  bool validateLoginPassword(String value, {required String emptyMessage}) {
    if (value.isEmpty) {
      _setLoginPasswordError(emptyMessage);
      return false;
    }
    _setLoginPasswordError(null);
    return true;
  }

  bool validateSpecialty(String value, {required String emptyMessage}) {
    if (value.trim().isEmpty) {
      _setSpecialtyError(emptyMessage);
      return false;
    }
    _setSpecialtyError(null);
    return true;
  }

  void updatePassword(
    String value, {
    required String tooShort,
    required String needSpecial,
    required String needUpper,
    required String mismatch,
  }) {
    password = value;
    _validatePasswords(tooShort: tooShort, needSpecial: needSpecial, needUpper: needUpper, mismatch: mismatch);
  }

  void updateConfirmPassword(
    String value, {
    required String tooShort,
    required String needSpecial,
    required String needUpper,
    required String mismatch,
  }) {
    confirmPassword = value;
    _validatePasswords(tooShort: tooShort, needSpecial: needSpecial, needUpper: needUpper, mismatch: mismatch);
  }

  void _validatePasswords({
    required String tooShort,
    required String needSpecial,
    required String needUpper,
    required String mismatch,
  }) {
    String? passError;
    if (password.length < 8) {
      passError = tooShort;
    } else if (!RegExp(r'[\\.,\\+\\*\\?]').hasMatch(password)) {
      passError = needSpecial;
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      passError = needUpper;
    }

    String? confirmError;
    if (confirmPassword.isNotEmpty && password != confirmPassword) {
      confirmError = mismatch;
    }

    passwordError = passError;
    confirmPasswordError = confirmError;
    notifyListeners();
  }

  bool validatePasswordsOnSubmit({
    required String tooShort,
    required String needSpecial,
    required String needUpper,
    required String mismatch,
  }) {
    password = passwordController.text;
    confirmPassword = confirmController.text;
    _validatePasswords(tooShort: tooShort, needSpecial: needSpecial, needUpper: needUpper, mismatch: mismatch);
    if (confirmPassword.isEmpty) {
      confirmPasswordError = mismatch;
      notifyListeners();
    }
    return passwordError == null && confirmPasswordError == null;
  }

  String? validatePhone(PhoneNumber? phone, {required String emptyMessage, required String invalidPrefixMessage}) {
    phoneNumber = '';
    if (phone == null || phone.number.isEmpty) {
      _setPhoneError(emptyMessage);
      return emptyMessage;
    }
    if (phone.countryCode == '+213' && !RegExp(r'^[567]').hasMatch(phone.number)) {
      _setPhoneError(invalidPrefixMessage);
      return invalidPrefixMessage;
    }
    phoneNumber = phone.completeNumber;
    _setPhoneError(null);
    return null;
  }

  void handlePhoneChanged(PhoneNumber phone, {required String invalidPrefixMessage}) {
    phoneNumber = '';
    if (phone.countryCode == '+213' && phone.number.isNotEmpty) {
      if (!RegExp(r'^[567]').hasMatch(phone.number) || phone.number.length < 9) {
        _setPhoneError(invalidPrefixMessage);
      } else {
        phoneNumber = phone.completeNumber;
        _setPhoneError(null);
      }
      return;
    }
    phoneNumber = phone.completeNumber;
    _setPhoneError(null);
  }

  bool validatePhoneOnSubmit({required String emptyMessage}) {
    if (phoneNumber.isEmpty) {
      _setPhoneError(emptyMessage);
      return false;
    }
    return phoneError == null;
  }

  bool validateDoctorSignup({
    required String nameEmptyMessage,
    required String emailEmptyMessage,
    required String emailInvalidMessage,
    required String specialtyEmptyMessage,
    required String phoneEmptyMessage,
    required String passwordTooShort,
    required String passwordNeedSpecial,
    required String passwordNeedUpper,
    required String passwordMismatch,
  }) {
    final nameOk = validateName(nameController.text, emptyMessage: nameEmptyMessage);
    final emailOk = validateEmail(
      emailController.text,
      emptyMessage: emailEmptyMessage,
      invalidMessage: emailInvalidMessage,
    );
    final specialtyOk = validateSpecialty(specialtyController.text, emptyMessage: specialtyEmptyMessage);
    final phoneOk = validatePhoneOnSubmit(emptyMessage: phoneEmptyMessage);
    final passwordOk = validatePasswordsOnSubmit(
      tooShort: passwordTooShort,
      needSpecial: passwordNeedSpecial,
      needUpper: passwordNeedUpper,
      mismatch: passwordMismatch,
    );
    return nameOk && emailOk && specialtyOk && phoneOk && passwordOk;
  }

  Future<String?> registerDoctor({
    required String fullname,
    required String email,
    required String phone,
    required String password,
    required String speciality,
    String? photoUrl,
  }) async {
    markActivity();
    final uri = Uri.parse('$apiBaseUrl/auth/signup');
    final payload = <String, dynamic>{
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'password': password,
      'speciality': speciality,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (photoBase64 != null && photoExtension != null) 'photo_base64': photoBase64,
      if (photoBase64 != null && photoExtension != null) 'photo_ext': photoExtension,
    };

    try {
      final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
      if (response.statusCode == 201) {
        return null;
      }

      String? message;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] != null) {
          message = decoded['error'].toString();
        }
      } catch (_) {}

      return message ?? 'Signup failed.';
    } catch (err) {
      return err.toString();
    }
  }

  bool validateDoctorLogin({
    required String emailEmptyMessage,
    required String emailInvalidMessage,
    required String passwordEmptyMessage,
  }) {
    setLoginSubmitError(null);
    final emailOk = validateLoginEmail(
      emailController.text,
      emptyMessage: emailEmptyMessage,
      invalidMessage: emailInvalidMessage,
    );
    final passwordOk = validateLoginPassword(passwordController.text, emptyMessage: passwordEmptyMessage);
    return emailOk && passwordOk;
  }

  Future<String?> loginDoctor({
    required String email,
    required String password,
    required String invalidMessage,
    required String genericMessage,
    required String networkMessage,
  }) async {
    setLoginSubmitError(null);
    markActivity();
    final uri = Uri.parse('$apiBaseUrl/auth/login');
    final payload = <String, dynamic>{'email': email, 'password': password};

    try {
      final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
      if (response.statusCode == 200) {
        int? userId;
        Map<String, dynamic>? userData;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            userData = Map<String, dynamic>.from(decoded);
            if (decoded['id_user'] != null) {
              userId = decoded['id_user'] is int ? decoded['id_user'] as int : int.tryParse('${decoded['id_user']}');
            }
          }
        } catch (_) {}

        if (userId != null) {
          _startSession(userId);
        }
        if (userData != null) {
          _setGlobalUser(userData);
        }
        setLoginSubmitError(null);
        return null;
      }

      if (response.statusCode == 401 || response.statusCode == 404) {
        setLoginSubmitError(invalidMessage);
        return invalidMessage;
      }

      String? message;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] != null) {
          message = decoded['error'].toString();
        }
      } catch (_) {}

      final error = message ?? genericMessage;
      setLoginSubmitError(error);
      return error;
    } catch (_) {
      setLoginSubmitError(networkMessage);
      return networkMessage;
    }
  }

  bool get canContinue => phoneNumber.isNotEmpty;

  static Future<void> restoreGlobals() async {
    final data = await SessionStorage.load();
    if (data == null || data.user == null) return;
    final lastActivity = data.lastActivity;
    if (lastActivity != null && DateTime.now().difference(lastActivity) > sessionTimeoutDuration) {
      await SessionStorage.clear();
      return;
    }
    globalUserId = data.userId;
    globalUser = data.user;
    globalClinic = data.clinic;
    _globalLastActivity = lastActivity ?? DateTime.now();
    _scheduleGlobalTimeout();
  }

  static Future<void> persistGlobals() async {
    await SessionStorage.save(
      userId: globalUserId,
      user: globalUser,
      clinic: globalClinic,
      lastActivity: _globalLastActivity,
    );
  }

  static void _scheduleGlobalTimeout() {
    if (_globalLastActivity == null) return;
    final idleFor = DateTime.now().difference(_globalLastActivity!);
    if (idleFor >= sessionTimeoutDuration) {
      _globalTimer?.cancel();
      _globalTimer = null;
      SessionStorage.clear();
      globalUserId = null;
      globalUser = null;
      globalClinic = null;
      _globalLastActivity = null;
      return;
    }
    final remaining = sessionTimeoutDuration - idleFor;
    _globalTimer?.cancel();
    _globalTimer = Timer(remaining, () {
      SessionStorage.clear();
      globalUserId = null;
      globalUser = null;
      globalClinic = null;
      _globalLastActivity = null;
    });
  }
}
