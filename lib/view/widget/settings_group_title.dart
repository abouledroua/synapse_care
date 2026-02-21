import 'package:flutter/material.dart';

class SettingsGroupTitle extends StatelessWidget {
  const SettingsGroupTitle({super.key, required this.title});

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
