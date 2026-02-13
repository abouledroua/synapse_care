import 'package:flutter/material.dart';

class RoleIcon extends StatelessWidget {
  const RoleIcon({super.key, required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3.0),
    child: (imagePath != null)
        ? Image.asset(imagePath!, height: 42, width: 42, fit: BoxFit.contain)
        : Icon(Icons.person, size: 32, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
  );
}
