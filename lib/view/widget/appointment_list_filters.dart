import 'package:flutter/material.dart';

import '../../controller/appointment_list_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';

class AppointmentListFilters extends StatelessWidget {
  const AppointmentListFilters({
    super.key,
    required this.controller,
    required this.onPickDate,
    required this.onPickPeriodStart,
    required this.onPickPeriodEnd,
  });

  final AppointmentListController controller;
  final VoidCallback onPickDate;
  final VoidCallback onPickPeriodStart;
  final VoidCallback onPickPeriodEnd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width >= LayoutConstants.wideBreakpoint;

    final searchField = TextField(
      controller: controller.searchController,
      onChanged: controller.onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.homeSearchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.searchController.text.isEmpty
            ? null
            : IconButton(onPressed: controller.clearSearch, icon: const Icon(Icons.close)),
        filled: true,
        fillColor: scheme.surface.withValues(alpha: 0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );

    final filterField = SizedBox(
      width: 130,
      child: DropdownButtonFormField<AppointmentFilterMode>(
        value: controller.filterMode,
        decoration: InputDecoration(
          labelText: l10n.appointmentFilterLabel,
          filled: true,
          fillColor: scheme.surface.withValues(alpha: 0.9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: [
          DropdownMenuItem(value: AppointmentFilterMode.date, child: Text(l10n.appointmentFilterDate)),
          DropdownMenuItem(value: AppointmentFilterMode.period, child: Text(l10n.appointmentFilterPeriod)),
          DropdownMenuItem(value: AppointmentFilterMode.all, child: Text(l10n.appointmentFilterAll)),
        ],
        onChanged: (mode) {
          if (mode == null) return;
          controller.setFilterMode(mode);
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: searchField),
              const SizedBox(width: 12),
              filterField,
              if (_buildFilterControls(fromLabel: l10n.appointmentFilterFrom, toLabel: l10n.appointmentFilterTo).isNotEmpty)
                const SizedBox(width: 12),
              Row(
                children: _buildFilterControls(
                  fromLabel: l10n.appointmentFilterFrom,
                  toLabel: l10n.appointmentFilterTo,
                ),
              ),
            ],
          )
        else ...[
          searchField,
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              filterField,
              if (_buildFilterControls(fromLabel: l10n.appointmentFilterFrom, toLabel: l10n.appointmentFilterTo).isNotEmpty)
                const SizedBox(width: 12),
              if (_buildFilterControls(fromLabel: l10n.appointmentFilterFrom, toLabel: l10n.appointmentFilterTo).isNotEmpty)
                Column(
                  children: _buildFilterControls(
                    fromLabel: l10n.appointmentFilterFrom,
                    toLabel: l10n.appointmentFilterTo,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> _buildFilterControls({required String fromLabel, required String toLabel}) =>
      (controller.filterMode == AppointmentFilterMode.date)
      ? [
          OutlinedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(controller.formatDate(controller.selectedDate)),
          ),
        ]
      : (controller.filterMode == AppointmentFilterMode.period)
      ? [
          OutlinedButton.icon(
            onPressed: onPickPeriodStart,
            icon: const Icon(Icons.calendar_month),
            label: Text('$fromLabel: ${controller.formatDate(controller.periodStart)}'),
          ),
          const SizedBox(width: 2),
          OutlinedButton.icon(
            onPressed: onPickPeriodEnd,
            icon: const Icon(Icons.calendar_month),
            label: Text('$toLabel: ${controller.formatDate(controller.periodEnd)}'),
          ),
        ]
      : const <Widget>[];
}
