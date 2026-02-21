import 'package:flutter/material.dart';

class SettingsComingSoonCard extends StatelessWidget {
  const SettingsComingSoonCard({super.key, required this.text});

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
