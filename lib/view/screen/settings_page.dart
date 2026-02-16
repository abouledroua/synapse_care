import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/settings_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';
import '../widget/app_background.dart';
import '../widget/app_footer.dart';
import '../widget/flag_icon.dart';
import '../widget/settings_widgets.dart';

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
      final currentCode = _controller.currentLanguageCode;
      final themeIndex = _controller.themeIndex;

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
                                    _GroupChip(
                                      label: l10n.settingsGroupGlobal,
                                      selected: _selectedGroup == _SettingsGroup.global,
                                      onTap: () => setState(() => _selectedGroup = _SettingsGroup.global),
                                    ),
                                    const SizedBox(width: 8),
                                    _GroupChip(
                                      label: l10n.settingsGroupAppointment,
                                      selected: _selectedGroup == _SettingsGroup.appointment,
                                      onTap: () => setState(() => _selectedGroup = _SettingsGroup.appointment),
                                    ),
                                    const SizedBox(width: 8),
                                    _GroupChip(
                                      label: l10n.settingsGroupConsultation,
                                      selected: _selectedGroup == _SettingsGroup.consultation,
                                      onTap: () => setState(() => _selectedGroup = _SettingsGroup.consultation),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_selectedGroup == _SettingsGroup.global) ...[
                                _SettingsGroupTitle(title: l10n.settingsGroupGlobal),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: scheme.surface.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.chooseLanguage,
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          LanguageFlagTile(
                                            type: FlagType.england,
                                            value: 'en',
                                            groupValue: currentCode,
                                            onChanged: _controller.setLanguage,
                                          ),
                                          const SizedBox(width: 12),
                                          LanguageFlagTile(
                                            type: FlagType.france,
                                            value: 'fr',
                                            groupValue: currentCode,
                                            onChanged: _controller.setLanguage,
                                          ),
                                          const SizedBox(width: 12),
                                          LanguageFlagTile(
                                            type: FlagType.algeria,
                                            value: 'ar',
                                            groupValue: currentCode,
                                            onChanged: _controller.setLanguage,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: scheme.surface.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.settingsThemeTitle,
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ThemeColorTile(
                                            title: l10n.settingsThemePurple,
                                            value: 1,
                                            groupValue: themeIndex,
                                            color: const Color(0xFFE5DBF3),
                                            onChanged: _controller.setTheme,
                                          ),
                                          ThemeColorTile(
                                            title: l10n.settingsThemeBlue,
                                            value: 2,
                                            groupValue: themeIndex,
                                            color: const Color(0xFFD6E8FA),
                                            onChanged: _controller.setTheme,
                                          ),
                                          ThemeColorTile(
                                            title: l10n.settingsThemeRose,
                                            value: 3,
                                            groupValue: themeIndex,
                                            color: const Color(0xFFF6D8E5),
                                            onChanged: _controller.setTheme,
                                          ),
                                          ThemeColorTile(
                                            title: l10n.settingsThemeGreen,
                                            value: 4,
                                            groupValue: themeIndex,
                                            color: const Color(0xFFD9EEDB),
                                            onChanged: _controller.setTheme,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (_selectedGroup == _SettingsGroup.appointment) ...[
                                _SettingsGroupTitle(title: l10n.settingsGroupAppointment),
                                const SizedBox(height: 8),
                                _ComingSoonCard(text: l10n.settingsComingSoon),
                              ] else ...[
                                _SettingsGroupTitle(title: l10n.settingsGroupConsultation),
                                const SizedBox(height: 8),
                                _ComingSoonCard(text: l10n.settingsComingSoon),
                              ],
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

enum _SettingsGroup { global, appointment, consultation }

class _GroupChip extends StatelessWidget {
  const _GroupChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.16)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? scheme.primary.withValues(alpha: 0.5) : scheme.outline.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SettingsGroupTitle extends StatelessWidget {
  const _SettingsGroupTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.w800),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: scheme.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(18)),
      child: Text(
        text,
        style: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
