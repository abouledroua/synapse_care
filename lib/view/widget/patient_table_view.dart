import 'package:flutter/material.dart';

import '../../core/utils/patient_formatters.dart';
import '../../l10n/app_localizations.dart';

class PatientTableView extends StatelessWidget {
  const PatientTableView({
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
    final scrollController = ScrollController();
    final columns = [
      DataColumn(label: Text(l10n.patientHeaderFullName)),
      DataColumn(label: Text(l10n.patientHeaderSexe)),
      const DataColumn(label: Text('NIN')),
      const DataColumn(label: Text('NSS')),
      DataColumn(label: Text(l10n.patientHeaderAge)),
      DataColumn(label: Text(l10n.patientHeaderPhone)),
      const DataColumn(label: Text('Email')),
      DataColumn(label: Text(l10n.patientHeaderAddress)),
      DataColumn(label: Text(l10n.patientHeaderDebt)),
      DataColumn(label: Text(l10n.patientHeaderBloodGroup)),
      DataColumn(label: SizedBox(width: 72, child: Text(l10n.patientHeaderActions))),
    ];

    return LayoutBuilder(
      builder: (context, constraints) => ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(true),
          thickness: WidgetStateProperty.all(10),
          radius: const Radius.circular(8),
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => scheme.primary.withValues(alpha: states.contains(WidgetState.dragged) ? 0.9 : 0.65),
          ),
          trackColor: WidgetStateProperty.all(scheme.primary.withValues(alpha: 0.15)),
          trackBorderColor: WidgetStateProperty.all(scheme.primary.withValues(alpha: 0.25)),
        ),
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(scheme.primary.withValues(alpha: 0.08)),
                  columns: columns,
                  rows: patients.map((item) {
                    final nom = (item['nom'] ?? '').toString();
                    final prenom = (item['prenom'] ?? '').toString();
                    final displayName = '${prenom.isEmpty ? '' : '$prenom '}$nom'.trim();
                    final sexe = PatientFormatters.formatSexe(
                      item['sexe'],
                      maleLabel: l10n.patientSexMale,
                      femaleLabel: l10n.patientSexFemale,
                    );
                    final nin = (item['nin'] ?? '').toString();
                    final nss = (item['nss'] ?? '').toString();
                    final age = PatientFormatters.formatAge(
                      item['age'],
                      item['type_age'],
                      yearsLabel: l10n.patientAgeYears,
                      monthsLabel: l10n.patientAgeMonths,
                      daysLabel: l10n.patientAgeDays,
                    );
                    final tel = (item['tel1'] ?? '').toString();
                    final email = (item['email'] ?? '').toString();
                    final adresse = (item['adresse'] ?? '').toString();
                    final dette = (item['dette'] ?? '').toString();
                    final gs = PatientFormatters.formatGs(item['gs']);
                    return DataRow(
                      cells: [
                        DataCell(Text(displayName.isEmpty ? l10n.homePatientSearchUnnamed : displayName)),
                        DataCell(Text(sexe)),
                        DataCell(Text(nin)),
                        DataCell(Text(nss)),
                        DataCell(Text(age)),
                        DataCell(Text(tel)),
                        DataCell(Text(email)),
                        DataCell(Text(adresse)),
                        DataCell(Text(dette)),
                        DataCell(Text(gs)),
                        DataCell(
                          SizedBox(
                            width: 72,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => onUpdate(item),
                                  icon: Icon(Icons.edit_outlined, color: scheme.primary),
                                  tooltip: l10n.patientActionUpdate,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  onPressed: () => onDelete(item),
                                  icon: Icon(Icons.delete_outline, color: scheme.error),
                                  tooltip: l10n.patientActionDelete,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
