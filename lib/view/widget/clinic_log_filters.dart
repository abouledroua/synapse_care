import 'package:flutter/material.dart';

import '../../controller/clinic_log_controller.dart';
import '../../l10n/app_localizations.dart';

class ClinicLogFilters extends StatelessWidget {
  const ClinicLogFilters({
    super.key,
    required this.controller,
    required this.onPickDate,
    required this.onPickFrom,
    required this.onPickTo,
  });

  final ClinicLogController controller;
  final Future<void> Function() onPickDate;
  final Future<void> Function() onPickFrom;
  final Future<void> Function() onPickTo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <DropdownMenuItem<ClinicLogFilterMode>>[
      DropdownMenuItem(value: ClinicLogFilterMode.date, child: Text(l10n.appointmentFilterDate)),
      DropdownMenuItem(value: ClinicLogFilterMode.period, child: Text(l10n.appointmentFilterPeriod)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<ClinicLogFilterMode>(
                value: controller.filterMode,
                items: items,
                onChanged: (value) {
                  if (value == null) return;
                  controller.setFilterMode(value);
                  controller.refresh();
                },
                decoration: InputDecoration(
                  labelText: l10n.appointmentFilterLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (controller.filterMode == ClinicLogFilterMode.date)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(controller.formatDate(controller.selectedDate)),
                ),
              ),
          ],
        ),
        if (controller.filterMode == ClinicLogFilterMode.period) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickFrom,
                  icon: const Icon(Icons.event),
                  label: Text('${l10n.appointmentFilterFrom}: ${controller.formatDate(controller.periodStart)}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickTo,
                  icon: const Icon(Icons.event_available),
                  label: Text('${l10n.appointmentFilterTo}: ${controller.formatDate(controller.periodEnd)}'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
