import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../l10n/app_localizations.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.scheme,
    required this.isWide,
    required this.l10n,
    this.patientCount,
    this.todayAppointmentCount,
    this.nextTodayAppointment,
  });

  final ColorScheme scheme;
  final bool isWide;
  final AppLocalizations l10n;
  final int? patientCount;
  final int? todayAppointmentCount;
  final Map<String, dynamic>? nextTodayAppointment;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashboardPadding = 16.0;
          const spacing = 10.0;
          const minCardWidth = 260.0;
          final available = max(0.0, constraints.maxWidth - (dashboardPadding * 2));
          final rawColumns = ((available + spacing) / (minCardWidth + spacing)).floor();
          final columns = max(1, min(3, rawColumns));
          var cardWidth = (available - spacing * (columns - 1)) / columns;
          cardWidth -= dashboardPadding / 2;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(dashboardPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.surface.withValues(alpha: 0.55), scheme.primaryContainer.withValues(alpha: 0.18)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 26, offset: Offset(0, 14))],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -60,
                  top: -40,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [scheme.primary.withValues(alpha: 0.18), Colors.transparent]),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeDashboardTitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: isWide ? 26 : 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        _DashWideCard(
                          width: available,
                          scheme: scheme,
                          title: l10n.homeDashNextTitle,
                          subtitle: l10n.homeDashNextSubtitle,
                          icon: FontAwesomeIcons.clock,
                          nextAppointment: nextTodayAppointment,
                          l10n: l10n,
                        ),
                        _DashCard(
                          width: cardWidth,
                          scheme: scheme,
                          title: l10n.homeDashAppointments,
                          value: todayAppointmentCount?.toString() ?? '—',
                          icon: FontAwesomeIcons.calendarCheck,
                          accent: scheme.primary,
                        ),
                        _DashCard(
                          width: cardWidth,
                          scheme: scheme,
                          title: l10n.homeDashConsultationsToday,
                          value: '8',
                          icon: FontAwesomeIcons.stethoscope,
                          accent: scheme.primary,
                        ),
                        _DashCard(
                          width: cardWidth,
                          scheme: scheme,
                          title: l10n.homeDashPatients,
                          value: patientCount?.toString() ?? '—',
                          icon: FontAwesomeIcons.userGroup,
                          accent: scheme.secondary,
                        ),
                        _DashCard(
                          width: cardWidth,
                          scheme: scheme,
                          title: l10n.homeDashRevenue,
                          value: '2.4k',
                          icon: FontAwesomeIcons.wallet,
                          accent: scheme.tertiary,
                        ),
                        _DashCard(
                          width: cardWidth,
                          scheme: scheme,
                          title: l10n.homeDashAlerts,
                          value: '3',
                          icon: FontAwesomeIcons.bell,
                          accent: scheme.error,
                        ),
                        _DashCard(
                          width: cardWidth,
                          scheme: scheme,
                          title: l10n.homeDashConsultationsMonth,
                          value: '128',
                          icon: FontAwesomeIcons.chartLine,
                          accent: scheme.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.width,
    required this.scheme,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final double width;
  final ColorScheme scheme;
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
            child: Center(child: FaIcon(icon, size: 28, color: accent.withValues(alpha: 0.9))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashWideCard extends StatelessWidget {
  const _DashWideCard({
    required this.width,
    required this.scheme,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.nextAppointment,
    required this.l10n,
  });

  final double width;
  final ColorScheme scheme;
  final String title;
  final String subtitle;
  final IconData icon;
  final Map<String, dynamic>? nextAppointment;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final next = nextAppointment;
    final nom = '${next?['nom'] ?? ''}'.trim();
    final prenom = '${next?['prenom'] ?? ''}'.trim();
    final fullName = '$prenom $nom'.trim();
    final queueNumber = int.tryParse('${next?['num_rdv'] ?? ''}') ?? 0;
    final motif = '${next?['motif_rdv'] ?? ''}'.trim();
    final hasNext = next != null;
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary.withValues(alpha: 0.15), scheme.surface.withValues(alpha: 0.12)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: FaIcon(icon, size: 28, color: scheme.primary)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                if (!hasNext)
                  Text(
                    l10n.homeDashNoMoreAppointments,
                    style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13),
                  )
                else ...[
                  Text(
                    '${queueNumber > 0 ? '#$queueNumber - ' : ''}${fullName.isEmpty ? l10n.homePatientSearchUnnamed : fullName}',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    motif.isEmpty ? '—' : motif,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
