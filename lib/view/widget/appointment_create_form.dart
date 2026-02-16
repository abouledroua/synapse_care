import 'package:flutter/material.dart';

import '../../controller/appointment_create_controller.dart';
import '../../l10n/app_localizations.dart';

class AppointmentCreateForm extends StatelessWidget {
  const AppointmentCreateForm({
    super.key,
    required this.controller,
    required this.onPickPatient,
    required this.onPickDate,
    required this.onPickTime,
    required this.onSave,
  });

  final AppointmentCreateController controller;
  final Future<void> Function() onPickPatient;
  final Future<void> Function() onPickDate;
  final Future<void> Function() onPickTime;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photoUrl = controller.selectedPatientPhotoUrl();
    final activeText = controller.activeAppointmentBannerText(l10n);
    return AbsorbPointer(
      absorbing: controller.saving,
      child: Column(
        children: [
          TextField(
            controller: controller.patientSearchController,
            focusNode: controller.patientSearchFocusNode,
            readOnly: true,
            onTap: onPickPatient,
            decoration: InputDecoration(
              labelText: l10n.patient,
              hintText: l10n.homeSearchHint,
              border: const OutlineInputBorder(),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(6),
                child: CircleAvatar(
                  radius: 14,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person_search_outlined, size: 16) : null,
                ),
              ),
              suffixIcon: controller.selectedPatientId == null
                  ? null
                  : IconButton(onPressed: controller.clearSelectedPatient, icon: const Icon(Icons.close)),
            ),
          ),
          if (controller.checkingActiveAppointment)
            const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator(minHeight: 2)),
          if (activeText != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(activeText),
            ),
          ],
          if (!controller.checkingActiveAppointment) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(controller.formatDate(controller.selectedDate)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(controller.formatTime(controller.selectedTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.motifController,
              minLines: 2,
              maxLines: null,
              decoration: InputDecoration(labelText: l10n.appointmentReasonLabel, border: const OutlineInputBorder()),
            ),
          ],
          if (!controller.checkingActiveAppointment) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.saving ? null : onSave,
                icon: controller.saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(controller.saving ? l10n.patientCreateSaving : l10n.patientCreateSubmit),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
