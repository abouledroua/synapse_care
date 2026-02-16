import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/phone_number.dart';

import 'auth_controller.dart';
import '../l10n/app_localizations.dart';
import '../services/patient_service.dart';

enum PatientSubmitResult { success, patientExists, noClinic, failed }

class PatientCreateController extends ChangeNotifier {
  PatientCreateController({PatientService? service}) : _service = service ?? PatientService();

  final PatientService _service;

  final codeBarre = TextEditingController();
  final nom = TextEditingController();
  final prenom = TextEditingController();
  final dateNaissance = TextEditingController();
  final email = TextEditingController();
  final age = TextEditingController();
  final tel1 = TextEditingController();
  final tel2 = TextEditingController();
  final adresse = TextEditingController();
  final pourcConv = TextEditingController();
  final lieuNaissance = TextEditingController();
  final profession = TextEditingController();
  final nin = TextEditingController();
  final nss = TextEditingController();
  final nationalite = TextEditingController();
  final formScrollController = ScrollController();

  final ImagePicker _imagePicker = ImagePicker();
  DateTime? birthDate;
  XFile? photo;
  Uint8List? photoBytes;
  String? photoExtension;
  String? existingPhotoFile;
  int? patientId;

  int sexe = 1;
  int typeAge = 1;
  int? gs;
  int? nationalityCode;
  int presume = 0;
  int conventionne = 0;
  String phoneCountryCode1 = 'DZ';
  String phoneCountryCode2 = 'DZ';
  bool saving = false;
  String? lastError;
  bool lastCreateLinked = false;
  int? existingPatientId;
  Map<String, dynamic>? existingPatientData;
  bool _identityCheckRunning = false;
  String _lastIdentityFingerprint = '';

  bool get isEditing => patientId != null;

  void initialize({Map<String, dynamic>? patient}) {
    if (patient != null) {
      loadFromPatient(patient);
      return;
    }
    _applyDefaultNationalityForCreate();
  }

  @override
  void dispose() {
    codeBarre.dispose();
    nom.dispose();
    prenom.dispose();
    dateNaissance.dispose();
    email.dispose();
    age.dispose();
    tel1.dispose();
    tel2.dispose();
    adresse.dispose();
    pourcConv.dispose();
    lieuNaissance.dispose();
    profession.dispose();
    nin.dispose();
    nss.dispose();
    nationalite.dispose();
    formScrollController.dispose();
    super.dispose();
  }

  String? requiredValidator(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.fieldRequired;
    return null;
  }

  String? optionalIntValidator(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return l10n.fieldInvalidNumber;
    if (parsed <= 0) return l10n.fieldInvalidNumber;
    if (typeAge == 3 && parsed > 30) return l10n.fieldInvalidNumber;
    return null;
  }

  String? optionalDoubleValidator(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) return l10n.fieldInvalidNumber;
    return null;
  }

  String? phoneValidator(PhoneNumber? phone, AppLocalizations l10n) {
    if (phone == null || phone.number.trim().isEmpty) return null;
    return null;
  }

  void setBirthDate(DateTime value, {bool syncAge = true}) {
    final now = DateTime.now();
    if (value.isAfter(DateTime(now.year, now.month, now.day))) {
      return;
    }
    birthDate = value;
    dateNaissance.text = DateFormat('yyyy-MM-dd').format(value);
    if (syncAge) {
      final totalMonths = (now.year - value.year) * 12 + (now.month - value.month);
      final beforeDay = now.day < value.day;
      final adjustedMonths = totalMonths - (beforeDay ? 1 : 0);
      if (adjustedMonths < 1) {
        typeAge = 3;
        final days = DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(DateTime(value.year, value.month, value.day)).inDays;
        age.text = (days < 0 ? 0 : days).toString();
      } else if (adjustedMonths < 12) {
        typeAge = 2;
        age.text = adjustedMonths.toString();
      } else {
        var years = adjustedMonths ~/ 12;
        if (years < 0) years = 0;
        typeAge = 1;
        age.text = years.toString();
      }
    }
    notifyListeners();
  }

  void loadFromPatient(Map<String, dynamic> patient) {
    patientId = patient['id_patient'] is num
        ? (patient['id_patient'] as num).toInt()
        : int.tryParse('${patient['id_patient'] ?? ''}');
    codeBarre.text = (patient['code_barre'] ?? '').toString();
    nom.text = (patient['nom'] ?? '').toString();
    prenom.text = (patient['prenom'] ?? '').toString();
    final rawDate = (patient['date_naissance'] ?? '').toString();
    final parsedDate = DateTime.tryParse(rawDate);
    dateNaissance.text = parsedDate == null ? rawDate : DateFormat('yyyy-MM-dd').format(parsedDate.toLocal());
    email.text = (patient['email'] ?? '').toString();
    age.text = (patient['age'] ?? '').toString();
    tel1.text = (patient['tel1'] ?? '').toString();
    tel2.text = (patient['tel2'] ?? '').toString();
    adresse.text = (patient['adresse'] ?? '').toString();
    pourcConv.text = (patient['pourc_conv'] ?? '').toString();
    lieuNaissance.text = (patient['lieu_naissance'] ?? '').toString();
    profession.text = (patient['profession'] ?? '').toString();
    nin.text = (patient['nin'] ?? '').toString();
    nss.text = (patient['nss'] ?? '').toString();
    final rawNationality = patient['nationality'];
    nationalityCode = rawNationality is num ? rawNationality.toInt() : int.tryParse('$rawNationality');
    if (nationalityCode != null) {
      final country = CountryParser.tryParsePhoneCode('$nationalityCode');
      nationalite.text = country?.name ?? '';
    } else {
      nationalite.text = (patient['nationalite'] ?? '').toString();
    }

    sexe = patient['sexe'] is num ? (patient['sexe'] as num).toInt() : int.tryParse('${patient['sexe'] ?? ''}') ?? 1;
    typeAge = patient['type_age'] is num
        ? (patient['type_age'] as num).toInt()
        : int.tryParse('${patient['type_age'] ?? ''}') ?? 1;
    gs = patient['gs'] is num ? (patient['gs'] as num).toInt() : int.tryParse('${patient['gs'] ?? ''}');
    if (gs == -1) gs = null;
    presume = patient['presume'] is num
        ? (patient['presume'] as num).toInt()
        : int.tryParse('${patient['presume'] ?? ''}') ?? 0;
    conventionne = patient['conventionne'] is num
        ? (patient['conventionne'] as num).toInt()
        : int.tryParse('${patient['conventionne'] ?? ''}') ?? 0;

    existingPhotoFile = (patient['photo_url'] ?? '').toString();
    if (parsedDate != null) {
      birthDate = parsedDate;
    }
    notifyListeners();
  }

  void syncDobFromAge() {
    final raw = age.text.trim();
    if (raw.isEmpty) {
      birthDate = null;
      dateNaissance.clear();
      notifyListeners();
      return;
    }
    final parsedAge = int.tryParse(raw);
    if (parsedAge == null || parsedAge < 0) return;
    if (typeAge == 3 && parsedAge > 30) {
      age.clear();
      birthDate = null;
      dateNaissance.clear();
      notifyListeners();
      return;
    }
    final now = DateTime.now();
    DateTime calculated;
    switch (typeAge) {
      case 2:
        final totalMonths = (now.year * 12 + (now.month - 1)) - parsedAge;
        final year = totalMonths ~/ 12;
        final month = (totalMonths % 12) + 1;
        calculated = DateTime(year, month, 1);
        break;
      case 3:
        calculated = DateTime(now.year, now.month, now.day).subtract(Duration(days: parsedAge));
        break;
      default:
        calculated = DateTime(now.year - parsedAge, 1, 1);
    }
    birthDate = calculated;
    dateNaissance.text = DateFormat('yyyy-MM-dd').format(calculated);
    notifyListeners();
  }

  Future<void> pickPhoto() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final bytes = kIsWeb ? await picked.readAsBytes() : null;
    photo = picked;
    photoBytes = (bytes != null && bytes.isNotEmpty) ? bytes : null;
    photoExtension = _extensionFromPath(picked.path);
    if (photo != null) {
      // Ensure local preview takes precedence over previously stored server image.
      existingPhotoFile = null;
    }
    notifyListeners();
  }

  void clearPhoto() {
    photo = null;
    photoBytes = null;
    photoExtension = null;
    notifyListeners();
  }

  ImageProvider? photoProvider() {
    if (photo != null) {
      if (kIsWeb) {
        if (photoBytes != null && photoBytes!.isNotEmpty) {
          return MemoryImage(photoBytes!);
        }
        return null;
      }
      return FileImage(File(photo!.path));
    }
    final existing = existingPhotoFile?.trim() ?? '';
    if (existing.isNotEmpty) {
      final url = _service.patientPhotoUrl(existing);
      if (url != null) return NetworkImage(url);
    }
    return null;
  }

  void setSexe(int value) {
    sexe = value;
    notifyListeners();
  }

  void setTypeAge(int value) {
    typeAge = value;
    final parsedAge = int.tryParse(age.text.trim());
    if (typeAge == 3 && parsedAge != null && parsedAge > 30) {
      age.clear();
      birthDate = null;
      dateNaissance.clear();
    }
    syncDobFromAge();
  }

  void setGs(int value) {
    gs = value;
    notifyListeners();
  }

  void setNationaliteName(String? value) {
    nationalite.text = (value ?? '').trim();
    notifyListeners();
  }

  void setNationaliteCountry(Country country) {
    nationalite.text = country.name.trim();
    nationalityCode = int.tryParse(country.phoneCode);
    if (!isEditing) {
      final tel1Empty = tel1.text.trim().isEmpty || tel1.text.trim() == '+213';
      final tel2Empty = tel2.text.trim().isEmpty || tel2.text.trim() == '+213';
      if (tel1Empty) phoneCountryCode1 = country.countryCode;
      if (tel2Empty) phoneCountryCode2 = country.countryCode;
    }
    notifyListeners();
  }

  void setNationaliteFromPhoneCode(String phoneCode) {
    final country = CountryParser.tryParsePhoneCode(phoneCode);
    if (country == null) return;
    nationalite.text = country.name.trim();
    nationalityCode = int.tryParse(country.phoneCode);
    if (!isEditing) {
      final tel1Empty = tel1.text.trim().isEmpty || tel1.text.trim() == '+213';
      final tel2Empty = tel2.text.trim().isEmpty || tel2.text.trim() == '+213';
      if (tel1Empty) phoneCountryCode1 = country.countryCode;
      if (tel2Empty) phoneCountryCode2 = country.countryCode;
    }
    notifyListeners();
  }

  void setPresume(bool value) {
    presume = value ? 1 : 0;
    notifyListeners();
  }

  void setConventionne(bool value) {
    conventionne = value ? 1 : 0;
    notifyListeners();
  }

  String phoneFieldValue(String completeNumber) {
    final raw = completeNumber.trim();
    if (raw.startsWith('+213')) return raw.substring(4);
    if (raw.startsWith('213')) return raw.substring(3);
    return raw;
  }

  Future<bool> submit() async {
    saving = true;
    lastError = null;
    lastCreateLinked = false;
    existingPatientId = null;
    existingPatientData = null;
    notifyListeners();
    try {
      final cabinetId = AuthController.globalClinic?['id_cabinet'];
      final userId = AuthController.globalUserId;
      if (cabinetId == null) {
        lastError = 'no_clinic';
        return false;
      }
      if (userId == null) {
        lastError = 'network';
        return false;
      }
      final bytes = photoBytes ?? await photo?.readAsBytes();
      final ageValue = int.tryParse(age.text.trim()) ?? 0;
      final pourcConvValue = double.tryParse(pourcConv.text.trim().replaceAll(',', '.')) ?? 0;
      final rawTel1 = tel1.text.trim() == '+213' ? '' : tel1.text.trim();
      final rawTel2 = tel2.text.trim() == '+213' ? '' : tel2.text.trim();
      final effectiveTel1 = rawTel1.isEmpty && rawTel2.isNotEmpty ? rawTel2 : rawTel1;
      final effectiveTel2 = rawTel1.isEmpty && rawTel2.isNotEmpty ? '' : rawTel2;
      final payload = <String, dynamic>{
        'id_cabinet': cabinetId,
        'id_user': userId,
        'nom': nom.text.trim(),
        'prenom': prenom.text.trim(),
        'date_naissance': dateNaissance.text.trim(),
        'email': email.text.trim(),
        'age': ageValue,
        'tel1': effectiveTel1,
        'adresse': adresse.text.trim(),
        'presume': presume,
        'sexe': sexe,
        'type_age': typeAge,
        'conventionne': conventionne,
        'pourc_conv': pourcConvValue,
        'lieu_naissance': lieuNaissance.text.trim(),
        'gs': gs ?? -1,
        'profession': profession.text.trim(),
        'diagnostique': '',
        'tel2': effectiveTel2,
        'nin': nin.text.trim(),
        'nss': nss.text.trim(),
        if (nationalityCode != null) 'nationality': nationalityCode,
        if (bytes != null && bytes.isNotEmpty) 'photo_base64': base64Encode(bytes),
        if (bytes != null && bytes.isNotEmpty) 'photo_ext': photoExtension ?? _extensionFromPath(photo?.path ?? ''),
      };
      if (isEditing) {
        final result = await _service.updatePatient(patientId!, payload);
        if (result['status'] == 409 && result['can_link'] == true) {
          lastError = 'patient_exists';
          final patient = result['patient'];
          if (patient is Map && patient['id_patient'] != null) {
            existingPatientId = patient['id_patient'] is num
                ? (patient['id_patient'] as num).toInt()
                : int.tryParse('${patient['id_patient']}');
            existingPatientData = Map<String, dynamic>.from(patient);
          }
          return false;
        }
      } else {
        final result = await _service.createPatient(payload);
        if (result['status'] == 409 && result['can_link'] == true) {
          lastError = 'patient_exists';
          final patient = result['patient'];
          if (patient is Map && patient['id_patient'] != null) {
            existingPatientId = patient['id_patient'] is num
                ? (patient['id_patient'] as num).toInt()
                : int.tryParse('${patient['id_patient']}');
            existingPatientData = Map<String, dynamic>.from(patient);
          }
          return false;
        }
        lastCreateLinked = result['linked'] == true;
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<PatientSubmitResult> submitWithResult() async {
    final ok = await submit();
    if (ok) return PatientSubmitResult.success;
    if (lastError == 'patient_exists') return PatientSubmitResult.patientExists;
    if (lastError == 'no_clinic') return PatientSubmitResult.noClinic;
    return PatientSubmitResult.failed;
  }

  Future<bool> linkExistingPatient() async {
    final cabinetId = AuthController.globalClinic?['id_cabinet'];
    final userId = AuthController.globalUserId;
    final patientId = existingPatientId;
    final parsedCabinetId = cabinetId is num ? cabinetId.toInt() : int.tryParse('$cabinetId');
    final parsedUserId = userId;
    if (parsedCabinetId == null || patientId == null || parsedUserId == null) return false;
    try {
      await _service.linkPatient(cabinetId: parsedCabinetId, patientId: patientId, userId: parsedUserId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> checkExistingIdentityInClinic() async {
    if (isEditing) return 'none';
    if (_identityCheckRunning) return 'none';
    final cabinetId = AuthController.globalClinic?['id_cabinet'];
    final userId = AuthController.globalUserId;
    final nationality = nationalityCode;
    final safeNin = nin.text.trim();
    final safeNss = nss.text.trim();
    final parsedCabinetId = cabinetId is num ? cabinetId.toInt() : int.tryParse('$cabinetId');
    if (parsedCabinetId == null || userId == null || nationality == null) return 'none';
    if (safeNin.isEmpty && safeNss.isEmpty) return 'none';

    final fingerprint = '$nationality|$safeNin|$safeNss';
    if (fingerprint == _lastIdentityFingerprint) return 'none';
    _identityCheckRunning = true;
    try {
      final result = await _service.checkExistingByIdentity(
        cabinetId: parsedCabinetId,
        userId: userId,
        nationality: nationality,
        nin: safeNin,
        nss: safeNss,
      );
      _lastIdentityFingerprint = fingerprint;
      final exists = result['exists'] == true;
      if (!exists) return 'none';
      final patient = result['patient'];
      if (patient is Map && patient['id_patient'] != null) {
        existingPatientId = patient['id_patient'] is num
            ? (patient['id_patient'] as num).toInt()
            : int.tryParse('${patient['id_patient']}');
        existingPatientData = Map<String, dynamic>.from(patient);
      }
      if (result['already_linked'] == true) return 'already_linked';
      return 'exists';
    } catch (_) {
      return 'error';
    } finally {
      _identityCheckRunning = false;
    }
  }

  String? existingPatientPhotoUrl() {
    final file = '${existingPatientData?['photo_url'] ?? ''}'.trim();
    if (file.isEmpty) return null;
    return _service.patientPhotoUrl(file);
  }

  String _extensionFromPath(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return 'jpg';
    return path.substring(dot + 1).toLowerCase();
  }

  void _applyDefaultNationalityForCreate() {
    if (isEditing || nationalite.text.trim().isNotEmpty) return;
    final clinicDefault = AuthController.globalClinic?['nationalite_patient_defaut'];
    final phoneCode = clinicDefault is num ? clinicDefault.toInt().toString() : '$clinicDefault';
    setNationaliteFromPhoneCode(phoneCode.trim().isEmpty ? '213' : phoneCode.trim());
  }
}
