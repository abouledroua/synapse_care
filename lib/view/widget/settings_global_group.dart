import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'flag_icon.dart';
import 'settings_group_title.dart';
import 'settings_widgets.dart';

class SettingsGlobalGroup extends StatelessWidget {
  const SettingsGlobalGroup({
    super.key,
    required this.l10n,
    required this.scheme,
    required this.currentLanguageCode,
    required this.themeIndex,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final String currentLanguageCode;
  final int themeIndex;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<int> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroupTitle(title: l10n.settingsGroupGlobal),
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
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SettingsLanguageFlagTile(
                    type: FlagType.england,
                    value: 'en',
                    groupValue: currentLanguageCode,
                    onChanged: onLanguageChanged,
                  ),
                  const SizedBox(width: 12),
                  SettingsLanguageFlagTile(
                    type: FlagType.france,
                    value: 'fr',
                    groupValue: currentLanguageCode,
                    onChanged: onLanguageChanged,
                  ),
                  const SizedBox(width: 12),
                  SettingsLanguageFlagTile(
                    type: FlagType.algeria,
                    value: 'ar',
                    groupValue: currentLanguageCode,
                    onChanged: onLanguageChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  l10n.settingsThemeTitle,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final pWidth = ((constraints.maxWidth - 50) / 4).clamp(70.0, 120.0);
                  debugPrint('Available width: ${constraints.maxWidth}, Calculated tile width: $pWidth');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SettingsThemeColorTile(
                        title: l10n.settingsThemePurple,
                        value: 1,
                        groupValue: themeIndex,
                        color: const Color(0xFFE5DBF3),
                        onChanged: onThemeChanged,
                        width: pWidth,
                      ),
                      SettingsThemeColorTile(
                        title: l10n.settingsThemeBlue,
                        value: 2,
                        groupValue: themeIndex,
                        color: const Color(0xFFD6E8FA),
                        onChanged: onThemeChanged,
                        width: pWidth,
                      ),
                      SettingsThemeColorTile(
                        title: l10n.settingsThemeRose,
                        value: 3,
                        groupValue: themeIndex,
                        color: const Color(0xFFF6D8E5),
                        onChanged: onThemeChanged,
                        width: pWidth,
                      ),
                      SettingsThemeColorTile(
                        title: l10n.settingsThemeGreen,
                        value: 4,
                        groupValue: themeIndex,
                        color: const Color(0xFFD9EEDB),
                        onChanged: onThemeChanged,
                        width: pWidth,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
