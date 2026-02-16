import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/appointment_create_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/app_background.dart';
import '../widget/app_footer.dart';
import '../widget/appointment_create_form.dart';

class AppointmentCreatePage extends StatefulWidget {
  const AppointmentCreatePage({super.key, this.initialPatient});

  final Map<String, dynamic>? initialPatient;

  @override
  State<AppointmentCreatePage> createState() => _AppointmentCreatePageState();
}

class _AppointmentCreatePageState extends State<AppointmentCreatePage> {
  final AppointmentCreateController _controller = AppointmentCreateController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final l10n = AppLocalizations.of(context)!;
      final initial = widget.initialPatient;
      if (initial != null) {
        await _controller.selectPatient(
          initial,
          yearsLabel: l10n.patientAgeYears,
          monthsLabel: l10n.patientAgeMonths,
          daysLabel: l10n.patientAgeDays,
        );
        return;
      }
      await _pickPatient(forceIfEmpty: true);
    });
  }

  Future<void> _pickPatient({bool forceIfEmpty = false}) async {
    if (!mounted) return;
    if (forceIfEmpty && _controller.selectedPatientId != null) return;
    final selected = await context.push<Map<String, dynamic>>(
      '/patients/list?picker=1',
    );
    if (!mounted) return;
    if (selected == null) {
      if (forceIfEmpty && _controller.selectedPatientId == null) {
        context.pop(false);
      }
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await _controller.selectPatient(
      selected,
      yearsLabel: l10n.patientAgeYears,
      monthsLabel: l10n.patientAgeMonths,
      daysLabel: l10n.patientAgeDays,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      barrierDismissible: false,
      initialDate: _controller.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    _controller.setDate(picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _controller.selectedTime ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    _controller.setTime(picked);
  }

  Future<void> _save() async {
    final ok = await _controller.save();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.appointmentCreateSuccess)));
      context.pop(true);
      return;
    }
    String message = l10n.appointmentCreateFailed;
    if (_controller.lastError == 'missing_patient') {
      message = l10n.appointmentPatientRequired;
    } else if (_controller.lastError == 'missing_time') {
      message = l10n.appointmentTimeRequired;
    } else if ((_controller.lastError ?? '').isNotEmpty) {
      message = (_controller.lastError ?? '')
          .replaceFirst('Exception: ', '')
          .trim();
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                      onPressed: _controller.saving ? null : () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        l10n.homeMenuRdvTake,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: AppointmentCreateForm(
                          controller: _controller,
                          onPickPatient: _pickPatient,
                          onPickDate: _pickDate,
                          onPickTime: _pickTime,
                          onSave: _save,
                        ),
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
