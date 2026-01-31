import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../services/patient_service.dart';
import '../widget/patient_list_view.dart';
import '../widget/patient_table_view.dart';
import '../widget/synapse_background.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final PatientService _service = PatientService();
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _patients = await _service.fetchPatients();
    } catch (_) {
      _error = 'network';
      _patients = [];
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  void _handleUpdate(Map<String, dynamic> patient) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.patientListUpdateComingSoon)));
  }

  void _handleDelete(Map<String, dynamic> patient) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.patientListDeleteComingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSuperWide = size.width >= LayoutConstants.superWideBreakpoint;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const SynapseBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), color: scheme.primary),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      l10n.patientListTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(l10n.patientListAddComingSoon)));
                          },
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                          label: Text(l10n.patientListAddNew),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _loadPatients,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.patientListRefresh),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? Center(
                            child: Text(l10n.loginNetworkError, style: TextStyle(color: scheme.error)),
                          )
                        : _patients.isEmpty
                        ? Center(
                            child: Text(
                              l10n.homePatientSearchEmpty,
                              style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                            ),
                          )
                        : isSuperWide
                        ? PatientTableView(
                            patients: _patients,
                            scheme: scheme,
                            l10n: l10n,
                            onUpdate: _handleUpdate,
                            onDelete: _handleDelete,
                          )
                        : PatientListView(
                            patients: _patients,
                            scheme: scheme,
                            l10n: l10n,
                            onUpdate: _handleUpdate,
                            onDelete: _handleDelete,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
