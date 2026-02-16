import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/appointment_list_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/app_background.dart';
import '../widget/app_footer.dart';
import '../widget/appointment_list_actions.dart';
import '../widget/appointment_list_body.dart';
import '../widget/appointment_list_filters.dart';

class AppointmentListPageV2 extends StatefulWidget {
  const AppointmentListPageV2({super.key});

  @override
  State<AppointmentListPageV2> createState() => _AppointmentListPageV2State();
}

class _AppointmentListPageV2State extends State<AppointmentListPageV2> {
  final AppointmentListController _controller = AppointmentListController();

  @override
  void initState() {
    super.initState();
    _controller.refresh();
  }

  Future<void> _pickSelectedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    _controller.setSelectedDate(picked);
  }

  Future<void> _pickPeriodStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.periodStart ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    _controller.setPeriodStart(picked);
  }

  Future<void> _pickPeriodEnd() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.periodEnd ?? _controller.periodStart ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    _controller.setPeriodEnd(picked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Scaffold(
        bottomNavigationBar: const AppFooter(),
        body: Stack(
          children: [
            const AppBackground(showFooter: false),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        l10n.homeMenuRdvList,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppointmentListActions(
                      loading: _controller.loading,
                      onRefresh: _controller.refresh,
                      onAdd: () async {
                        final created = await context.push<bool>('/appointments/create');
                        if (!mounted) return;
                        if (created == true) {
                          _controller.refresh();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    AppointmentListFilters(
                      controller: _controller,
                      onPickDate: _pickSelectedDate,
                      onPickPeriodStart: _pickPeriodStart,
                      onPickPeriodEnd: _pickPeriodEnd,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: AppointmentListBody(
                        controller: _controller,
                        onRefresh: _controller.refresh,
                        onChangeAppointment: (appointment) async {
                          final selectedPatient = <String, dynamic>{
                            'id_patient': appointment['id_patient'],
                            'nom': appointment['nom'],
                            'prenom': appointment['prenom'],
                            'age': appointment['age'],
                            'type_age': appointment['type_age'],
                            'photo_url': appointment['photo_url'],
                          };
                          final saved = await context.push<bool>(
                            '/appointments/create',
                            extra: selectedPatient,
                          );
                          if (!mounted) return;
                          if (saved == true) {
                            _controller.refresh();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
