import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'settings_coming_soon_card.dart';
import 'settings_group_title.dart';

class SettingsPrintingGroup extends StatelessWidget {
  const SettingsPrintingGroup({
    super.key,
    required this.l10n,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroupTitle(title: l10n.settingsGroupPrinting),
        const SizedBox(height: 8),
        SettingsComingSoonCard(text: l10n.settingsComingSoon),
      ],
    );
  }
}
