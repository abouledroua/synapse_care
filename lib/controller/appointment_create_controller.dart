import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';
import '../core/utils/patient_formatters.dart';
import '../l10n/app_localizations.dart';
import '../services/appointment_service.dart';
import '../services/patient_service.dart';

class AppointmentCreateController extends ChangeNotifier {
  AppointmentCreateController({AppointmentService? service}) : _service = service ?? AppointmentService() {
    patientSearchFocusNode.addListener(() {
      if (!patientSearchFocusNode.hasFocus) {
        enforcePatientSelectionOnBlur();
      }
    });
  }

  final AppointmentService _service;
  final PatientService _patientService = PatientService();
  final TextEditingController patientSearchController = TextEditingController();
  final FocusNode patientSearchFocusNode = FocusNode();
  final TextEditingController motifController = TextEditingController();
  Timer? _searchDebounce;

  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  bool saving = false;
  String? lastError;
  bool searchingPatients = false;
  int? selectedPatientId;
  String? selectedPatientPhotoFile;
  int? activeAppointmentId;
  DateTime? activeAppointmentDate;
  bool checkingActiveAppointment = false;
  List<Map<String, dynamic>> patientSearchResults = <Map<String, dynamic>>[];
  bool _settingPatientText = false;

  int? get cabinetId {
    final raw = AuthController.globalClinic?['id_cabinet'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  int? get userId => AuthController.globalUserId;

  String patientLabel(
    Map<String, dynamic> patient, {
    String yearsLabel = 'years',
    String monthsLabel = 'months',
    String daysLabel = 'days',
  }) {
    final nom = '${patient['nom'] ?? ''}'.trim();
    final prenom = '${patient['prenom'] ?? ''}'.trim();
    final fullName = '$prenom $nom'.trim();
    final ageText = PatientFormatters.formatAge(
      patient['age'],
      patient['type_age'],
      yearsLabel: yearsLabel,
      monthsLabel: monthsLabel,
      daysLabel: daysLabel,
    );
    if (fullName.isNotEmpty) {
      if (ageText.isNotEmpty) return '$fullName ($ageText)';
      return fullName;
    }
    final id = patient['id_patient'];
    return '#$id';
  }

  String? selectedPatientPhotoUrl() {
    final file = (selectedPatientPhotoFile ?? '').trim();
    if (file.isEmpty) return null;
    return _patientService.patientPhotoUrl(file);
  }

  String? activeAppointmentBannerText(AppLocalizations l10n) {
    if (activeAppointmentId == null || activeAppointmentDate == null) return null;
    final y = activeAppointmentDate!.year.toString().padLeft(4, '0');
    final m = activeAppointmentDate!.month.toString().padLeft(2, '0');
    final d = activeAppointmentDate!.day.toString().padLeft(2, '0');
    final date = '$y-$m-$d';
    return l10n.appointmentActiveExistsMessage(date);
  }

  Future<void> _checkActiveAppointment() async {
    if (cabinetId == null || userId == null || selectedPatientId == null) return;
    checkingActiveAppointment = true;
    notifyListeners();
    try {
      final active = await _service.fetchActiveAppointment(
        cabinetId: cabinetId!,
        userId: userId!,
        patientId: selectedPatientId!,
      );
      if (active == null) {
        activeAppointmentId = null;
        activeAppointmentDate = null;
        final today = DateTime.now();
        selectedDate = DateTime(today.year, today.month, today.day);
        selectedTime = null;
        motifController.clear();
        return;
      }
      final rawId = active['id_rdv'];
      if (rawId is int) {
        activeAppointmentId = rawId;
      } else if (rawId is num) {
        activeAppointmentId = rawId.toInt();
      } else if (rawId is String) {
        activeAppointmentId = int.tryParse(rawId);
      } else {
        activeAppointmentId = null;
      }
      final rawDate = '${active['date_rdv'] ?? ''}'.trim();
      activeAppointmentDate = DateTime.tryParse(rawDate);
      if (activeAppointmentDate != null) {
        selectedDate = DateTime(activeAppointmentDate!.year, activeAppointmentDate!.month, activeAppointmentDate!.day);
      }
      selectedTime = _parseTimeOfDay(active['heure_rdv']);
      motifController.text = '${active['motif_rdv'] ?? ''}'.trim();
    } catch (_) {
      activeAppointmentId = null;
      activeAppointmentDate = null;
      final today = DateTime.now();
      selectedDate = DateTime(today.year, today.month, today.day);
      selectedTime = null;
      motifController.clear();
    } finally {
      checkingActiveAppointment = false;
      notifyListeners();
    }
  }

  TimeOfDay? _parseTimeOfDay(dynamic rawValue) {
    if (rawValue == null) return null;
    final text = '$rawValue'.trim();
    if (text.isEmpty) return null;
    final parts = text.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  void onPatientQueryChanged(String value) {
    if (_settingPatientText) return;
    selectedPatientId = null;
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      patientSearchResults = <Map<String, dynamic>>[];
      searchingPatients = false;
      notifyListeners();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 250), () async {
      if (cabinetId == null || userId == null) return;
      searchingPatients = true;
      notifyListeners();
      try {
        final rows = await _patientService.searchPatients(query: query, cabinetId: cabinetId!, userId: userId!);
        patientSearchResults = rows.take(8).toList();
      } catch (_) {
        patientSearchResults = <Map<String, dynamic>>[];
      } finally {
        searchingPatients = false;
        notifyListeners();
      }
    });
  }

  Future<void> selectPatient(
    Map<String, dynamic> patient, {
    String yearsLabel = 'years',
    String monthsLabel = 'months',
    String daysLabel = 'days',
  }) async {
    final raw = patient['id_patient'];
    int? id;
    if (raw is int) {
      id = raw;
    } else if (raw is num) {
      id = raw.toInt();
    } else if (raw is String) {
      id = int.tryParse(raw);
    }
    if (id == null) return;
    selectedPatientId = id;
    selectedPatientPhotoFile = '${patient['photo_url'] ?? ''}';
    final label = patientLabel(patient, yearsLabel: yearsLabel, monthsLabel: monthsLabel, daysLabel: daysLabel);
    _settingPatientText = true;
    patientSearchController.value = TextEditingValue(
      text: label,
      selection: TextSelection.collapsed(offset: label.length),
    );
    _settingPatientText = false;
    patientSearchResults = <Map<String, dynamic>>[];
    notifyListeners();
    await _checkActiveAppointment();
  }

  void clearSelectedPatient() {
    selectedPatientId = null;
    selectedPatientPhotoFile = null;
    activeAppointmentId = null;
    activeAppointmentDate = null;
    patientSearchController.clear();
    patientSearchResults = <Map<String, dynamic>>[];
    notifyListeners();
  }

  void enforcePatientSelectionOnBlur() {
    final typed = patientSearchController.text.trim();
    if (typed.isEmpty) {
      selectedPatientId = null;
      patientSearchResults = <Map<String, dynamic>>[];
      notifyListeners();
      return;
    }
    if (selectedPatientId == null) {
      patientSearchController.clear();
      patientSearchResults = <Map<String, dynamic>>[];
      notifyListeners();
    }
  }

  void setDate(DateTime value) {
    selectedDate = value;
    notifyListeners();
  }

  void setTime(TimeOfDay value) {
    selectedTime = value;
    notifyListeners();
  }

  String formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<bool> save() async {
    lastError = null;
    if (cabinetId == null || userId == null) {
      lastError = 'no_clinic';
      return false;
    }
    if (selectedPatientId == null) {
      lastError = 'missing_patient';
      return false;
    }

    saving = true;
    notifyListeners();
    try {
      final payload = {
        'id_cabinet': cabinetId,
        'id_user': userId,
        'id_patient': selectedPatientId,
        'date_rdv': formatDate(selectedDate),
        'heure_rdv': selectedTime == null ? null : formatTime(selectedTime),
        'motif_rdv': motifController.text.trim(),
      };
      if (activeAppointmentId != null) {
        await _service.updateAppointment(activeAppointmentId!, payload);
      } else {
        await _service.createAppointment(payload);
      }
      return true;
    } catch (e) {
      lastError = '$e';
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    patientSearchFocusNode.dispose();
    patientSearchController.dispose();
    motifController.dispose();
    super.dispose();
  }
}
