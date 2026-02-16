import 'package:flutter/material.dart';

import 'flag_icon.dart';

class LanguageFlagTile extends StatelessWidget {
  const LanguageFlagTile({
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
            color: selected
                ? scheme.primary.withValues(alpha: 0.55)
                : scheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: FlagIcon(type: type, size: 32),
      ),
    );
  }
}

class ThemeRadioTile extends StatelessWidget {
  const ThemeRadioTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final int value;
  final int groupValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Radio<int>(
            value: value,
            groupValue: groupValue,
            activeColor: scheme.primary,
            onChanged: (_) => onChanged(value),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeColorTile extends StatelessWidget {
  const ThemeColorTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.color,
    required this.onChanged,
  });

  final String title;
  final int value;
  final int groupValue;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 118,
        height: 68,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.85)
                : scheme.outline.withValues(alpha: 0.25),
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
