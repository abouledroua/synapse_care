import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/constant/layout_constants.dart';
import '../../core/utils/patient_formatters.dart';
import '../../l10n/app_localizations.dart';

class PatientListView extends StatelessWidget {
  const PatientListView({
    super.key,
    required this.patients,
    required this.scheme,
    required this.l10n,
    required this.onUpdate,
    required this.onDelete,
    this.controller,
  });

  final List<Map<String, dynamic>> patients;
  final ColorScheme scheme;
  final AppLocalizations l10n;
  final ValueChanged<Map<String, dynamic>> onUpdate;
  final ValueChanged<Map<String, dynamic>> onDelete;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      itemCount: patients.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = patients[index];
        final nom = (item['nom'] ?? '').toString();
        final prenom = (item['prenom'] ?? '').toString();
        final sexeValue = item['sexe'];
        final sexeNumber = sexeValue is num ? sexeValue.toInt() : int.tryParse(sexeValue?.toString() ?? '');
        final isFemale = sexeNumber == 2;
        final tel = PatientFormatters.formatPhone(item['tel1']);
        final email = (item['email'] ?? '').toString();
        final nin = (item['nin'] ?? '').toString();
        final nss = (item['nss'] ?? '').toString();
        final age = PatientFormatters.formatAge(
          item['age'],
          item['type_age'],
          yearsLabel: l10n.patientAgeYears,
          monthsLabel: l10n.patientAgeMonths,
          daysLabel: l10n.patientAgeDays,
        );
        final adresse = (item['adresse'] ?? '').toString();
        final dette = PatientFormatters.formatDebt(
          item['dette'],
          localeName: l10n.localeName,
          currencyLatin: l10n.patientCurrencyDzdLatin,
          currencyArabic: l10n.patientCurrencyDzdArabic,
        );
        final gs = PatientFormatters.formatGs(item['gs']);
        final displayName = '${prenom.isEmpty ? '' : '$prenom '}$nom'.trim();
        final primaryItems = [
          _InfoItem(l10n.patientHeaderAge, age),
          _InfoItem(l10n.patientHeaderPhone, tel),
          _InfoItem(l10n.patientHeaderDebt, dette),
          _InfoItem(l10n.patientHeaderEmail, email),
        ];
        final extraItems = [
          _InfoItem(l10n.patientHeaderNin, nin),
          _InfoItem(l10n.patientHeaderAddress, adresse),
          _InfoItem(l10n.patientHeaderNss, nss),
          _InfoItem(l10n.patientHeaderBloodGroup, gs),
        ];
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          decoration: BoxDecoration(
            color: isFemale ? const Color(0xFFFFE6F0) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(left: 44, right: 8, bottom: 8),
              title: Row(
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
                          style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        _InfoWrap(items: primaryItems, scheme: scheme),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InkIcon(
                    icon: FontAwesomeIcons.penToSquare,
                    color: scheme.primary,
                    tooltip: l10n.patientActionUpdate,
                    onTap: () => onUpdate(item),
                  ),
                  const SizedBox(width: 8),
                  _InkIcon(
                    icon: FontAwesomeIcons.trashCan,
                    color: scheme.error,
                    tooltip: l10n.patientActionDelete,
                    onTap: () => onDelete(item),
                  ),
                ],
              ),
              children: [_InfoWrap(items: extraItems, scheme: scheme)],
            ),
          ),
        );
      },
    );
  }
}

class _InfoWrap extends StatelessWidget {
  const _InfoWrap({required this.items, required this.scheme});

  final List<_InfoItem> items;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final filtered = items.where((item) => item.value.trim().isNotEmpty).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = MediaQuery.of(context).size.width >= LayoutConstants.wideBreakpoint;
        final itemWidth = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 6,
          children: filtered
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.label}: ',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String value;
}

class _InkIcon extends StatelessWidget {
  const _InkIcon({required this.icon, required this.color, required this.tooltip, required this.onTap});

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FaIcon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}
