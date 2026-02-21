import 'package:flutter/material.dart';

import '../../controller/consultation_controller.dart';
import '../../l10n/app_localizations.dart';

class ConsultationSectionSelector extends StatelessWidget {
  const ConsultationSectionSelector({
    super.key,
    required this.selectedSection,
    required this.onSectionSelected,
    this.showLastConsultation = false,
    this.showSickLeave = true,
    this.showMedicalCertificates = true,
    this.showLabs = true,
    this.showOrientationLetter = true,
    this.showReports = true,
  });

  final ConsultationSection selectedSection;
  final ValueChanged<ConsultationSection> onSectionSelected;
  final bool showLastConsultation;
  final bool showSickLeave;
  final bool showMedicalCertificates;
  final bool showLabs;
  final bool showOrientationLetter;
  final bool showReports;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final sections = <(ConsultationSection section, String label)>[
      if (showLastConsultation) (ConsultationSection.lastConsultation, l10n.consultationSectionLastConsultation),
      (ConsultationSection.generalInfo, l10n.consultationSectionGeneralInfo),
      (ConsultationSection.prescriptions, l10n.consultationSectionPrescriptions),
      if (showSickLeave) (ConsultationSection.sickLeave, l10n.consultationSectionSickLeave),
      if (showMedicalCertificates)
        (
          ConsultationSection.medicalCertificates,
          l10n.consultationSectionMedicalCertificates,
        ),
      if (showLabs) (ConsultationSection.labs, l10n.consultationSectionLabs),
      if (showOrientationLetter)
        (ConsultationSection.orientationLetter, l10n.consultationSectionOrientationLetter),
      if (showReports) (ConsultationSection.reports, l10n.consultationReportsMedical),
      (ConsultationSection.nextAppointment, l10n.consultationSectionNextAppointment),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sections
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(item.$2),
                  selected: selectedSection == item.$1,
                  side: BorderSide(
                    color: selectedSection == item.$1 ? scheme.primary : scheme.outline.withValues(alpha: 0.45),
                    width: selectedSection == item.$1 ? 1.4 : 1,
                  ),
                  onSelected: (_) => onSectionSelected(item.$1),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
