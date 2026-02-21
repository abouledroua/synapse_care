import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/consultation_controller.dart';
import '../../controller/patient_list_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../services/patient_service.dart';
import '../widget/app_background.dart';
import '../widget/app_footer.dart';
import '../widget/consultation_patient_selector.dart';
import '../widget/consultation_section_body.dart';
import '../widget/consultation_section_selector.dart';
import '../widget/patient_list_view.dart';

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key, this.initialPatient});

  final Map<String, dynamic>? initialPatient;

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final ConsultationController _controller = ConsultationController();
  final PatientService _patientService = PatientService();
  PatientListController? _pickerController;
  bool _pickerDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.loadConsultationSettings();
      final l10n = AppLocalizations.of(context)!;
      final initial = widget.initialPatient;
      if (initial != null) {
        await _controller.selectPatient(
          initial,
          yearsLabel: l10n.patientAgeYears,
          monthsLabel: l10n.patientAgeMonths,
          daysLabel: l10n.patientAgeDays,
        );
        return;
      }
      await _pickPatient(forceIfEmpty: true);
    });
  }

  Future<void> _pickPatient({bool forceIfEmpty = false}) async {
    if (!mounted) return;
    if (forceIfEmpty && _controller.selectedPatientId != null) return;
    final selected = await _showPatientPickerDialog();
    if (!mounted) return;
    if (selected == null) {
      if (forceIfEmpty && _controller.selectedPatientId == null) {
        context.pop(false);
      }
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await _controller.selectPatient(
      selected,
      yearsLabel: l10n.patientAgeYears,
      monthsLabel: l10n.patientAgeMonths,
      daysLabel: l10n.patientAgeDays,
    );
  }

  Future<Map<String, dynamic>?> _showPatientPickerDialog() async {
    if (_pickerDialogOpen) return null;
    _pickerDialogOpen = true;
    _pickerController?.dispose();
    final pickerController = PatientListController();
    _pickerController = pickerController;
    await pickerController.loadPatients();
    if (!mounted) {
      _pickerDialogOpen = false;
      return null;
    }
    final picked = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        final l10n = AppLocalizations.of(dialogContext)!;
        return PopScope(
          canPop: false,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SizedBox(
              width: 920,
              height: 620,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: pickerController,
                  builder: (context, _) => Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.patientListTitle,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: scheme.onSurface),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: pickerController.searchController,
                        onChanged: pickerController.onSearchChanged,
                        decoration: InputDecoration(
                          hintText: l10n.homeSearchHint,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: pickerController.searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: pickerController.clearSearch,
                                  icon: const Icon(Icons.close),
                                ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: pickerController.loading
                            ? const Center(child: CircularProgressIndicator())
                            : pickerController.error != null
                            ? Center(
                                child: Text(
                                  pickerController.error == 'no_clinic'
                                      ? l10n.patientClinicRequired
                                      : l10n.loginNetworkError,
                                  style: TextStyle(color: scheme.error),
                                ),
                              )
                            : pickerController.patients.isEmpty
                            ? Center(
                                child: Text(
                                  l10n.homePatientSearchEmpty,
                                  style: TextStyle(color: scheme.onSurfaceVariant),
                                ),
                              )
                            : PatientListView(
                                controller: pickerController.listController,
                                patients: pickerController.patients,
                                scheme: scheme,
                                l10n: l10n,
                                pickerMode: true,
                                onSelect: (patient) => Navigator.of(dialogContext).pop(patient),
                                onUpdate: (_) {},
                                onDelete: (_) {},
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    _pickerDialogOpen = false;
    return picked;
  }

  void _onValidate() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsComingSoon)));
  }

  @override
  void dispose() {
    _pickerController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final photoUrl = _controller.selectedPatientPhotoUrl(_patientService.patientPhotoUrl);
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottomNavigationBar: const AppFooter(),
          appBar: AppBar(
            title: Text(l10n.homeMenuConsultation),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          body: Stack(
            children: [
              const AppBackground(showFooter: false),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConsultationPatientSelector(
                        controller: _controller,
                        photoUrl: photoUrl,
                        enabled: _controller.selectedPatientId == null,
                        onPickPatient: _pickPatient,
                        onClearPatient: _controller.clearSelectedPatient,
                      ),
                      if (_controller.selectedPatientId != null) ...[
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ConsultationSectionSelector(
                                  selectedSection: _controller.selectedSection,
                                  onSectionSelected: _controller.setSection,
                                  showLastConsultation: _controller.showLastConsultationSection,
                                  showSickLeave: _controller.arretTravailEnabled,
                                  showMedicalCertificates: _controller.certificatMedicalEnabled,
                                  showLabs: _controller.bilansEnabled,
                                  showOrientationLetter: _controller.lettreOrientationEnabled,
                                  showReports: _controller.rapportsMedicauxEnabled,
                                ),
                                const SizedBox(height: 14),
                                ConsultationSectionBody(section: _controller.selectedSection),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.pop(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                            ),
                          ),
                          const SizedBox(width: 20),
                          FilledButton(
                            onPressed: _controller.selectedPatientId == null ? null : _onValidate,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(MaterialLocalizations.of(context).okButtonLabel),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
