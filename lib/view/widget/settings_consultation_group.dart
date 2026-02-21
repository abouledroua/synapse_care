import 'package:flutter/material.dart';

import '../../controller/settings_consultation_controller.dart';
import '../../l10n/app_localizations.dart';
import 'settings_group_title.dart';

class SettingsConsultationGroup extends StatefulWidget {
  const SettingsConsultationGroup({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  State<SettingsConsultationGroup> createState() => _SettingsConsultationGroupState();
}

class _SettingsConsultationGroupState extends State<SettingsConsultationGroup> {
  late final SettingsConsultationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsConsultationController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final l10n = widget.l10n;
      final scheme = Theme.of(context).colorScheme;
      final items = <(String key, String label)>[
        ('certificat_medical_enabled', l10n.consultationSectionMedicalCertificate),
        ('bilans_enabled', l10n.consultationSectionLabs),
        ('lettre_orientation_enabled', l10n.consultationSectionOrientationLetter),
        ('arret_travail_enabled', l10n.consultationSectionSickLeave),
        ('rapports_medicaux_enabled', l10n.consultationReportsMedical),
      ];
      final prescriptionOptions = <(String value, String label)>[
        ('selection_medicaments', l10n.settingsConsultationPrescriptionModeSelectMedicaments),
        ('saisie_prescription', l10n.settingsConsultationPrescriptionModeManual),
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsGroupTitle(title: l10n.settingsGroupConsultation),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _controller.isLoading
                ? const Center(
                    child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsConsultationTogglesTitle,
                        style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      ...items.map((item) {
                        final enabled = _controller.isEnabled(item.$1);
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: enabled ? null : Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            dense: true,
                            title: Text(item.$2),
                            value: enabled,
                            onChanged: _controller.isSaving ? null : (value) => _controller.setEnabled(item.$1, value),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _controller.isLoading
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsConsultationPrescriptionGroupTitle,
                        style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: _controller.gestOrdonnance,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.settingsConsultationPrescriptionModeLabel,
                          border: const OutlineInputBorder(),
                        ),
                        items: prescriptionOptions
                            .map((item) => DropdownMenuItem<String>(value: item.$1, child: Text(item.$2)))
                            .toList(),
                        onChanged: _controller.isSaving
                            ? null
                            : (value) {
                                if (value == null) return;
                                _controller.setGestOrdonnance(value);
                              },
                      ),
                    ],
                  ),
          ),
        ],
      );
    },
  );
}
