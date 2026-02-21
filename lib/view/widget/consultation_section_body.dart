import 'package:flutter/material.dart';

import '../../controller/consultation_controller.dart';
import '../../l10n/app_localizations.dart';

class ConsultationSectionBody extends StatelessWidget {
  const ConsultationSectionBody({
    super.key,
    required this.section,
  });

  final ConsultationSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (section) {
      ConsultationSection.lastConsultation => _SectionCard(
          title: l10n.consultationSectionLastConsultation,
          icon: Icons.history_outlined,
          description: l10n.consultationSectionLastConsultationDesc,
        ),
      ConsultationSection.generalInfo => _SectionCard(
          title: l10n.consultationSectionGeneralInfo,
          icon: Icons.info_outline,
          description: l10n.consultationSectionGeneralInfoDesc,
        ),
      ConsultationSection.prescriptions => _SectionCard(
          title: l10n.consultationSectionPrescriptions,
          icon: Icons.receipt_long_outlined,
          description: l10n.consultationSectionPrescriptionsDesc,
        ),
      ConsultationSection.sickLeave => _SectionCard(
          title: l10n.consultationSectionSickLeave,
          icon: Icons.work_history_outlined,
          description: l10n.consultationSectionSickLeaveDesc,
        ),
      ConsultationSection.medicalCertificates => _SectionCard(
          title: l10n.consultationSectionMedicalCertificates,
          icon: Icons.fact_check_outlined,
          description: l10n.consultationSectionMedicalCertificatesDesc,
        ),
      ConsultationSection.labs => _SectionCard(
          title: l10n.consultationSectionLabs,
          icon: Icons.science_outlined,
          description: l10n.consultationSectionLabsDesc,
        ),
      ConsultationSection.orientationLetter => _SectionCard(
          title: l10n.consultationSectionOrientationLetter,
          icon: Icons.forward_to_inbox_outlined,
          description: l10n.consultationSectionOrientationLetterDesc,
        ),
      ConsultationSection.reports => _SectionCard(
          title: l10n.consultationReportsMedical,
          icon: Icons.description_outlined,
          description: l10n.consultationSectionReportsDesc,
        ),
      ConsultationSection.nextAppointment => _SectionCard(
          title: l10n.consultationSectionNextAppointment,
          icon: Icons.event_available_outlined,
          description: l10n.consultationSectionNextAppointmentDesc,
        ),
    };
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
