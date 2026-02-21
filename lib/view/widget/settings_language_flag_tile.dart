import 'package:flutter/material.dart';

import 'flag_icon.dart';

class SettingsLanguageFlagTile extends StatelessWidget {
  const SettingsLanguageFlagTile({
    super.key,
    required this.type,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final FlagType type;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 54,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.16)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? scheme.primary.withValues(alpha: 0.55) : scheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: FlagIcon(type: type, size: 32),
      ),
    );
  }
}
