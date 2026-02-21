import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/clinic_log_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/app_background.dart';
import '../widget/app_footer.dart';
import '../widget/clinic_log_filters.dart';
import '../widget/clinic_log_list.dart';

class ClinicLogPage extends StatefulWidget {
  const ClinicLogPage({super.key});

  @override
  State<ClinicLogPage> createState() => _ClinicLogPageState();
}

class _ClinicLogPageState extends State<ClinicLogPage> {
  final ClinicLogController _controller = ClinicLogController();

  @override
  void initState() {
    super.initState();
    _controller.refresh();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    _controller.setSelectedDate(picked);
    await _controller.refresh();
  }

  Future<void> _pickFrom() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.periodStart ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    _controller.setPeriodStart(picked);
  }

  Future<void> _pickTo() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.periodEnd ?? _controller.periodStart ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
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
                        l10n.homeMenuHistory,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClinicLogFilters(
                      controller: _controller,
                      onPickDate: _pickDate,
                      onPickFrom: _pickFrom,
                      onPickTo: _pickTo,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: _controller.loading ? null : _controller.refresh,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.appointmentListRefresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ClinicLogList(controller: _controller),
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
