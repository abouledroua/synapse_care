import 'package:flutter/material.dart';

import '../core/utils/patient_formatters.dart';
import '../services/cabinet_service.dart';
import 'auth_controller.dart';

enum ConsultationSection {
  lastConsultation,
  generalInfo,
  prescriptions,
  sickLeave,
  medicalCertificates,
  labs,
  orientationLetter,
  reports,
  nextAppointment,
}

class ConsultationController extends ChangeNotifier {
  ConsultationController({CabinetService? cabinetService})
      : _cabinetService = cabinetService ?? CabinetService();

  final CabinetService _cabinetService;
  final TextEditingController patientController = TextEditingController();

  int? selectedPatientId;
  String? selectedPatientPhotoFile;
  bool showLastConsultationSection = false;
  bool arretTravailEnabled = true;
  bool certificatMedicalEnabled = true;
  bool bilansEnabled = true;
  bool lettreOrientationEnabled = true;
  bool rapportsMedicauxEnabled = true;
  ConsultationSection selectedSection = ConsultationSection.generalInfo;

  int? get _cabinetId {
    final raw = AuthController.globalClinic?['id_cabinet'];
    if (raw is num) return raw.toInt();
    return int.tryParse('$raw');
  }

  int? get _userId => AuthController.globalUserId;

  String? selectedPatientPhotoUrl(String? Function(String) resolvePatientPhotoUrl) {
    final file = (selectedPatientPhotoFile ?? '').trim();
    if (file.isEmpty) return null;
    return resolvePatientPhotoUrl(file);
  }

  Future<void> selectPatient(
    Map<String, dynamic> patient, {
    required String yearsLabel,
    required String monthsLabel,
    required String daysLabel,
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
    final label = _patientLabel(
      patient,
      yearsLabel: yearsLabel,
      monthsLabel: monthsLabel,
      daysLabel: daysLabel,
    );
    patientController.value = TextEditingValue(
      text: label,
      selection: TextSelection.collapsed(offset: label.length),
    );
    notifyListeners();
  }

  void clearSelectedPatient() {
    selectedPatientId = null;
    selectedPatientPhotoFile = null;
    patientController.clear();
    notifyListeners();
  }

  void setSection(ConsultationSection section) {
    if (selectedSection == section) return;
    selectedSection = section;
    notifyListeners();
  }

  void setShowLastConsultationSection(bool value) {
    if (showLastConsultationSection == value) return;
    showLastConsultationSection = value;
    if (!showLastConsultationSection &&
        selectedSection == ConsultationSection.lastConsultation) {
      selectedSection = ConsultationSection.generalInfo;
    }
    notifyListeners();
  }

  Future<void> loadConsultationSettings() async {
    final cabinetId = _cabinetId;
    final userId = _userId;
    if (cabinetId == null || userId == null) {
      return;
    }
    try {
      final values = await _cabinetService.fetchConsultationParams(
        requesterUserId: userId,
        cabinetId: cabinetId,
      );
      final enabled = values['arret_travail_enabled'] ?? true;
      arretTravailEnabled = enabled;
      final medicalCertificateEnabled = values['certificat_medical_enabled'] ?? true;
      certificatMedicalEnabled = medicalCertificateEnabled;
      final labsEnabled = values['bilans_enabled'] ?? true;
      bilansEnabled = labsEnabled;
      final orientationEnabled = values['lettre_orientation_enabled'] ?? true;
      lettreOrientationEnabled = orientationEnabled;
      final reportsEnabled = values['rapports_medicaux_enabled'] ?? true;
      rapportsMedicauxEnabled = reportsEnabled;
      if (!arretTravailEnabled && selectedSection == ConsultationSection.sickLeave) {
        selectedSection = ConsultationSection.generalInfo;
      }
      if (!certificatMedicalEnabled &&
          selectedSection == ConsultationSection.medicalCertificates) {
        selectedSection = ConsultationSection.generalInfo;
      }
      if (!bilansEnabled && selectedSection == ConsultationSection.labs) {
        selectedSection = ConsultationSection.generalInfo;
      }
      if (!lettreOrientationEnabled &&
          selectedSection == ConsultationSection.orientationLetter) {
        selectedSection = ConsultationSection.generalInfo;
      }
      if (!rapportsMedicauxEnabled && selectedSection == ConsultationSection.reports) {
        selectedSection = ConsultationSection.generalInfo;
      }
      notifyListeners();
    } catch (_) {
      // Keep default behavior if settings cannot be loaded.
    }
  }

  String _patientLabel(
    Map<String, dynamic> patient, {
    required String yearsLabel,
    required String monthsLabel,
    required String daysLabel,
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
    return '#${patient['id_patient']}';
  }

  @override
  void dispose() {
    patientController.dispose();
    super.dispose();
  }
}
