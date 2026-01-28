import 'package:flutter/material.dart';
import 'role_card.dart';
import '../../l10n/app_localizations.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key, required this.isDoctor, required this.onChanged});

  final bool isDoctor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: RoleCard(
            label: l10n.patient,
            imagePath: 'assets/images/patient.png',
            selected: !isDoctor,
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RoleCard(
            label: l10n.doctor,
            imagePath: 'assets/images/doctor_tablier.png',
            selected: isDoctor,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}
