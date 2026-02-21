import 'package:flutter/material.dart';

import '../../controller/consultation_controller.dart';
import '../../l10n/app_localizations.dart';

class ConsultationPatientSelector extends StatelessWidget {
  const ConsultationPatientSelector({
    super.key,
    required this.controller,
    required this.photoUrl,
    required this.onPickPatient,
    required this.onClearPatient,
    required this.enabled,
  });

  final ConsultationController controller;
  final String? photoUrl;
  final Future<void> Function() onPickPatient;
  final VoidCallback onClearPatient;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller.patientController,
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? onPickPatient : null,
      decoration: InputDecoration(
        labelText: l10n.patient,
        hintText: l10n.homeSearchHint,
        border: const OutlineInputBorder(),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: CircleAvatar(
            radius: 14,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null ? const Icon(Icons.person_search_outlined, size: 16) : null,
          ),
        ),
        suffixIcon: controller.selectedPatientId == null
            ? null
            : IconButton(
                onPressed: onClearPatient,
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}
