import 'package:flutter/material.dart';

import '../../controller/settings_appointment_controller.dart';
import '../../l10n/app_localizations.dart';
import 'settings_group_title.dart';

class SettingsAppointmentGroup extends StatefulWidget {
  const SettingsAppointmentGroup({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  State<SettingsAppointmentGroup> createState() => _SettingsAppointmentGroupState();
}

class _SettingsAppointmentGroupState extends State<SettingsAppointmentGroup> {
  late final SettingsAppointmentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsAppointmentController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsGroupTitle(title: l10n.settingsGroupAppointment),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsAppointmentWorkingDaysTitle,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (_controller.isLoading)
                  const Center(
                    child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
                  )
                else
                  ..._buildDays(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDays(AppLocalizations l10n) {
    final days = <(int value, String label)>[
      (1, l10n.settingsAppointmentMonday),
      (2, l10n.settingsAppointmentTuesday),
      (3, l10n.settingsAppointmentWednesday),
      (4, l10n.settingsAppointmentThursday),
      (5, l10n.settingsAppointmentFriday),
      (6, l10n.settingsAppointmentSaturday),
      (7, l10n.settingsAppointmentSunday),
    ];

    return days.map((day) {
      final enabled = _controller.isDayEnabled(day.$1);
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: enabled ? null : Colors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          dense: true,
          title: Text(day.$2),
          subtitle: Text(enabled ? l10n.settingsAppointmentOpen : l10n.settingsAppointmentClosed),
          value: enabled,
          onChanged: _controller.isSaving ? null : (value) => _controller.setDayEnabled(day.$1, value),
        ),
      );
    }).toList();
  }
}
