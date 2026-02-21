import 'package:flutter/material.dart';

class SettingsThemeRadioTile extends StatelessWidget {
  const SettingsThemeRadioTile({
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
