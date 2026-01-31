import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../l10n/app_localizations.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    required this.l10n,
    required this.scheme,
    this.onPatientsTap,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final VoidCallback? onPatientsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 12,
        children: [
          _QuickActionChip(
            label: l10n.homeMenuPatientsList,
            icon: FontAwesomeIcons.userGroup,
            color: const Color(0xFF1F8A70),
            scheme: scheme,
            onTap: onPatientsTap,
          ),
          _QuickActionChip(
            label: l10n.homeMenuConsultation,
            icon: FontAwesomeIcons.stethoscope,
            color: const Color(0xFF3F6BB6),
            scheme: scheme,
          ),
          _QuickActionChip(
            label: l10n.homeMenuRdvList,
            icon: FontAwesomeIcons.calendarCheck,
            color: const Color(0xFFE39B27),
            scheme: scheme,
          ),
          _QuickActionChip(
            label: l10n.homeMenuCaisse,
            icon: FontAwesomeIcons.cashRegister,
            color: const Color(0xFF2D6A9F),
            scheme: scheme,
          ),
          _QuickActionChip(
            label: l10n.homeMenuSettings,
            icon: FontAwesomeIcons.gear,
            color: const Color(0xFF8E3B46),
            scheme: scheme,
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.scheme,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final ColorScheme scheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: content,
    );
  }
}
