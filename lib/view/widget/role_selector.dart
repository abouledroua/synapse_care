import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import 'role_card.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key, required this.role, required this.onChanged});

  final AuthRole role;
  final ValueChanged<AuthRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: RoleCard(
                label: l10n.patient,
                imagePath: 'assets/images/patient.png',
                selected: role == AuthRole.patient,
                onTap: () => onChanged(AuthRole.patient),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: RoleCard(
                label: l10n.staff,
                imagePath: 'assets/images/doctor.png',
                selected: role != AuthRole.patient,
                onTap: () => onChanged(AuthRole.doctor),
              ),
            ),
          ],
        );
      },
    );
  }
}
