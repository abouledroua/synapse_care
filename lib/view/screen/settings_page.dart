import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../controller/settings_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';
import '../widget/app_background.dart';
import '../widget/app_footer.dart';
import '../widget/settings_appointment_group.dart';
import '../widget/settings_consultation_group.dart';
import '../widget/settings_global_group.dart';
import '../widget/settings_group_chip.dart';
import '../widget/settings_printing_group.dart';
import '../widget/settings_logs_group.dart';
import '../widget/settings_users_group.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController _controller = SettingsController();
  _SettingsGroup _selectedGroup = _SettingsGroup.global;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context)!;
      final scheme = Theme.of(context).colorScheme;

      return Scaffold(
        bottomNavigationBar: const AppFooter(),
        body: Stack(
          children: [
            const AppBackground(showFooter: false),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: LayoutConstants.wideBreakpoint),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                          color: scheme.primary,
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            l10n.homeMenuSettings,
                            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: ListView(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SettingsGroupChip(
                                      label: l10n.settingsGroupGlobal,
                                      icon: FontAwesomeIcons.globe,
                                      selected: _selectedGroup == _SettingsGroup.global,
                                      onTap: () => setState(() => _selectedGroup = _SettingsGroup.global),
                                    ),
                                    const SizedBox(width: 8),
                                    SettingsGroupChip(
                                      label: l10n.settingsGroupAppointment,
                                      icon: FontAwesomeIcons.calendarCheck,
                                      selected: _selectedGroup == _SettingsGroup.appointment,
                                      onTap: () => setState(() => _selectedGroup = _SettingsGroup.appointment),
                                    ),
                                    const SizedBox(width: 8),
                                    SettingsGroupChip(
                                      label: l10n.settingsGroupConsultation,
                                      icon: FontAwesomeIcons.stethoscope,
                                      selected: _selectedGroup == _SettingsGroup.consultation,
                                      onTap: () => setState(() => _selectedGroup = _SettingsGroup.consultation),
                                    ),
                                    const SizedBox(width: 8),
                                    SettingsGroupChip(
                                      label: l10n.settingsGroupPrinting,
                                      icon: FontAwesomeIcons.print,
                                      selected: _selectedGroup == _SettingsGroup.printing,
                                      onTap: () => setState(() => _selectedGroup = _SettingsGroup.printing),
                                    ),
                                    const SizedBox(width: 8),
                                    SettingsGroupChip(
                                      label: l10n.settingsGroupUsers,
                                      icon: FontAwesomeIcons.users,
                                      selected: _selectedGroup == _SettingsGroup.users,
                                      onTap: () => setState(() => _selectedGroup = _SettingsGroup.users),
                                    ),
                                    const SizedBox(width: 8),
                                    SettingsGroupChip(
                                      label: l10n.homeMenuHistory,
                                      icon: FontAwesomeIcons.clipboardList,
                                      selected: _selectedGroup == _SettingsGroup.logs,
                                      onTap: () => setState(() => _selectedGroup = _SettingsGroup.logs),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_selectedGroup == _SettingsGroup.global)
                                SettingsGlobalGroup(
                                  l10n: l10n,
                                  scheme: scheme,
                                  currentLanguageCode: _controller.currentLanguageCode,
                                  themeIndex: _controller.themeIndex,
                                  onLanguageChanged: _controller.setLanguage,
                                  onThemeChanged: _controller.setTheme,
                                )
                              else if (_selectedGroup == _SettingsGroup.appointment)
                                SettingsAppointmentGroup(l10n: l10n)
                              else if (_selectedGroup == _SettingsGroup.consultation)
                                SettingsConsultationGroup(l10n: l10n)
                              else if (_selectedGroup == _SettingsGroup.printing)
                                SettingsPrintingGroup(l10n: l10n)
                              else if (_selectedGroup == _SettingsGroup.logs)
                                SettingsLogsGroup(l10n: l10n)
                              else
                                SettingsUsersGroup(l10n: l10n),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

enum _SettingsGroup { global, appointment, consultation, printing, users, logs }
