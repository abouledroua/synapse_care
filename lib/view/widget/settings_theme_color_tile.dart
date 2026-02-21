import 'package:flutter/material.dart';

class SettingsThemeColorTile extends StatelessWidget {
  const SettingsThemeColorTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.color,
    required this.onChanged,
    this.width = 70,
  });

  final String title;
  final int value;
  final int groupValue;
  final Color color;
  final ValueChanged<int> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        height: 65,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? scheme.primary.withValues(alpha: 0.85) : scheme.outline.withValues(alpha: 0.25),
            width: selected ? 2 : 1,
          ),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4))],
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
