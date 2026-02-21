import 'package:flutter/material.dart';

import '../../controller/clinic_log_controller.dart';
import '../../l10n/app_localizations.dart';
import 'clinic_log_filters.dart';
import 'clinic_log_list.dart';
import 'settings_group_title.dart';

class SettingsLogsGroup extends StatefulWidget {
  const SettingsLogsGroup({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  State<SettingsLogsGroup> createState() => _SettingsLogsGroupState();
}

class _SettingsLogsGroupState extends State<SettingsLogsGroup> {
  final ClinicLogController _controller = ClinicLogController();

  @override
  void initState() {
    super.initState();
    _controller.refresh();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    _controller.setSelectedDate(picked);
    await _controller.refresh();
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.periodStart ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    _controller.setPeriodStart(picked);
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.periodEnd ?? _controller.periodStart ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    _controller.setPeriodEnd(picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsGroupTitle(title: widget.l10n.homeMenuHistory),
          const SizedBox(height: 8),
          ClinicLogFilters(
            controller: _controller,
            onPickDate: _pickDate,
            onPickFrom: _pickFrom,
            onPickTo: _pickTo,
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _controller.loading ? null : _controller.refresh,
            icon: const Icon(Icons.refresh),
            label: Text(widget.l10n.appointmentListRefresh),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 420,
            child: ClinicLogList(controller: _controller),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
