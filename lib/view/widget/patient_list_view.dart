import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class PatientListView extends StatelessWidget {
  const PatientListView({
    super.key,
    required this.patients,
    required this.scheme,
    required this.l10n,
    required this.onUpdate,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> patients;
  final ColorScheme scheme;
  final AppLocalizations l10n;
  final ValueChanged<Map<String, dynamic>> onUpdate;
  final ValueChanged<Map<String, dynamic>> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = patients[index];
        final nom = (item['nom'] ?? '').toString();
        final prenom = (item['prenom'] ?? '').toString();
        final tel = (item['tel1'] ?? '').toString();
        final email = (item['email'] ?? '').toString();
        final displayName = '${prenom.isEmpty ? '' : '$prenom '}$nom'.trim();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10)),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                child: Icon(Icons.person_outline, color: scheme.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isEmpty ? l10n.homePatientSearchUnnamed : displayName,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tel.isNotEmpty ? tel : email,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onUpdate(item),
                icon: Icon(Icons.edit_outlined, color: scheme.primary),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                tooltip: l10n.patientActionUpdate,
              ),
              IconButton(
                onPressed: () => onDelete(item),
                icon: Icon(Icons.delete_outline, color: scheme.error),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                tooltip: l10n.patientActionDelete,
              ),
            ],
          ),
        );
      },
    );
  }
}
