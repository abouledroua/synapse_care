import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class HomeSideMenu extends StatelessWidget {
  const HomeSideMenu({
    super.key,
    required this.l10n,
    required this.scheme,
    required this.onHide,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
          onHide();
        }
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withValues(alpha: 0.96), scheme.primaryContainer.withValues(alpha: 0.75)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 22, offset: Offset(0, 12))],
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: ScrollConfiguration(
          behavior: const _MenuScrollBehavior(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MenuItem(icon: Icons.people_alt_outlined, label: l10n.homeMenuPatientsList, scheme: scheme),
                _MenuItem(icon: Icons.newspaper_outlined, label: l10n.homeMenuConsultation, scheme: scheme),
                _MenuItem(icon: Icons.history, label: l10n.homeMenuHistory, scheme: scheme),
                _MenuItem(icon: Icons.point_of_sale_outlined, label: l10n.homeMenuCaisse, scheme: scheme),
                _MenuItem(icon: Icons.settings_outlined, label: l10n.homeMenuSettings, scheme: scheme),
                _MenuItem(icon: Icons.storage_outlined, label: l10n.homeMenuData, scheme: scheme),
                _MenuItem(icon: Icons.info_outline, label: l10n.homeMenuAbout, scheme: scheme),
                _MenuItem(icon: Icons.event_available_outlined, label: l10n.homeMenuToday, scheme: scheme),
                _MenuItem(icon: Icons.event_note_outlined, label: l10n.homeMenuRdvTake, scheme: scheme),
                _MenuItem(icon: Icons.list_alt_outlined, label: l10n.homeMenuRdvList, scheme: scheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuScrollBehavior extends MaterialScrollBehavior {
  const _MenuScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.scheme});

  final IconData icon;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Icon(icon, color: scheme.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ],
    ),
  );
}
