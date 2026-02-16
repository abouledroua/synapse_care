import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../controller/appointment_list_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../core/utils/patient_formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../services/patient_service.dart';

class AppointmentListBody extends StatefulWidget {
  const AppointmentListBody({
    super.key,
    required this.controller,
    required this.onRefresh,
    required this.onChangeAppointment,
  });

  final AppointmentListController controller;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Map<String, dynamic> appointment) onChangeAppointment;

  @override
  State<AppointmentListBody> createState() => _AppointmentListBodyState();
}

class _AppointmentListBodyState extends State<AppointmentListBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final platform = Theme.of(context).platform;
    final isMobilePlatform =
        platform == TargetPlatform.android || platform == TargetPlatform.iOS;
    final isNarrowDevice =
        MediaQuery.of(context).size.width < LayoutConstants.wideBreakpoint;
    final isMobileDevice = isMobilePlatform || isNarrowDevice;
    final l10n = AppLocalizations.of(context)!;
    final items = widget.controller.filteredAppointments;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (widget.controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.homePatientSearchEmpty,
          style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
        ),
      );
    }

    final list = RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final nom = '${item['nom'] ?? ''}'.trim();
          final prenom = '${item['prenom'] ?? ''}'.trim();
          final fullName = '$prenom $nom'.trim();
          final appointmentDate = widget.controller.appointmentDate(item);
          final isToday =
              appointmentDate != null &&
              appointmentDate.year == today.year &&
              appointmentDate.month == today.month &&
              appointmentDate.day == today.day;
          final etatRdv = int.tryParse('${item['etat_rdv'] ?? ''}');
          final isPresent = etatRdv == 1;
          final showStatus = isToday && (etatRdv == 0 || etatRdv == 1);
          final numRdv = int.tryParse('${item['num_rdv'] ?? ''}') ?? 0;
          final showNumRdv = isToday && numRdv != 0;
          final ageText = PatientFormatters.formatAge(
            item['age'],
            item['type_age'],
            yearsLabel: l10n.patientAgeYears,
            monthsLabel: l10n.patientAgeMonths,
            daysLabel: l10n.patientAgeDays,
          );
          final motif = '${item['motif_rdv'] ?? ''}'.trim();
          final heureRdv = '${item['heure_rdv'] ?? ''}'.trim();
          final heureArrivee = '${item['heure_arrivee'] ?? ''}'.trim();
          final heureArriveeText =
              heureArrivee.length >= 5 ? heureArrivee.substring(0, 5) : heureArrivee;
          final dateRdv = widget.controller.formatDate(appointmentDate);
          final photoFile = '${item['photo_url'] ?? ''}'.trim();
          final imageUrl = PatientService().patientPhotoUrl(photoFile);
          final badgeBackground = isPresent ? const Color(0xFFE8F7EE) : const Color(0xFFFDEBEC);
          final badgeBorder = isPresent ? const Color(0xFF34A853) : const Color(0xFFEA4335);
          final badgeTextColor = isPresent ? const Color(0xFF1E7F3E) : const Color(0xFFB3261E);
          return Card(
            color: showStatus && isPresent ? const Color(0xFFEAF9F0) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 70,
                    height: 76,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                          child: imageUrl == null
                              ? FaIcon(FontAwesomeIcons.user, size: 16, color: scheme.onSurfaceVariant)
                              : null,
                        ),
                        if (showStatus) const SizedBox(height: 4),
                        if (showStatus)
                          _buildStatusBadge(showStatus, isPresent, l10n, badgeBackground, badgeBorder, badgeTextColor),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fullName.isEmpty ? l10n.homePatientSearchUnnamed : fullName,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (showNumRdv) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: scheme.primary.withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Text(
                                  '#$numRdv',
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text('${l10n.appointmentFilterDate}: $dateRdv')),
                          ],
                        ),
                        if (ageText.isNotEmpty)
                          Row(
                            children: [
                              Expanded(child: Text('${l10n.patientHeaderAge}: $ageText')),
                              InkWell(
                                onTap: () => widget.onChangeAppointment(item),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: FaIcon(
                                    FontAwesomeIcons.penToSquare,
                                    size: 20,
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => widget.onChangeAppointment(item),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: FaIcon(
                                  FontAwesomeIcons.penToSquare,
                                  size: 20,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ),
                        if (isToday && heureArriveeText.isNotEmpty)
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.clock,
                                size: 12,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(heureArriveeText),
                            ],
                          ),
                        if (motif.isNotEmpty) Text('${l10n.appointmentReasonLabel}: $motif'),
                        if (heureRdv.isNotEmpty) Text('${l10n.appointmentFilterTo}: $heureRdv'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (isMobileDevice) {
      return list;
    }

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(scheme.primary.withValues(alpha: 0.9)),
        trackColor: WidgetStatePropertyAll(scheme.primary.withValues(alpha: 0.18)),
        trackBorderColor: WidgetStatePropertyAll(scheme.primary.withValues(alpha: 0.35)),
        thickness: const WidgetStatePropertyAll(10),
        radius: const Radius.circular(12),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        child: list,
      ),
    );
  }

  Widget _buildStatusBadge(
    bool showStatus,
    bool isPresent,
    AppLocalizations l10n,
    Color badgeBackground,
    Color badgeBorder,
    Color badgeTextColor,
  ) {
    if (!showStatus) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: badgeBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            isPresent ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circleXmark,
            size: 12,
            color: badgeTextColor,
          ),
          const SizedBox(width: 4),
          Text(
            isPresent ? l10n.appointmentStatusPresent : l10n.appointmentStatusAbsent,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeTextColor),
          ),
        ],
      ),
    );
  }
}
