import 'package:flutter/material.dart';

class RoleIcon extends StatelessWidget {
  const RoleIcon({super.key, required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return (imagePath != null)
        ? Image.asset(imagePath!, height: 34, width: 34, fit: BoxFit.contain)
        : Icon(Icons.person, size: 32, color: scheme.primary.withValues(alpha: 0.7));
  }
}
