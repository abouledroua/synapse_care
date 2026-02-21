import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../controller/patient_list_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/patient_list_view.dart';
import '../widget/app_background.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({
    super.key,
    this.pickerMode = false,
  });

  final bool pickerMode;

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final PatientListController _controller = PatientListController();

  @override
  void initState() {
    super.initState();
    _controller.loadPatients();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.listFocusNode.requestFocus();
      }
    });
  }

  void _handleUpdate(Map<String, dynamic> patient) {
    context.push('/patients/edit', extra: patient).then((value) {
      if (value == true) {
        _controller.loadPatients();
      }
    });
  }

  void _handleDelete(Map<String, dynamic> patient) {
    final id = patient['id_patient'] is num
        ? (patient['id_patient'] as num).toInt()
        : int.tryParse('${patient['id_patient'] ?? ''}');
    if (id == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.patientDeleteFailed)));
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.patientDeleteConfirmTitle),
        content: Text(l10n.patientDeleteConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.patientDeleteCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.patientDeleteConfirm)),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      final ok = await _controller.deletePatient(id);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.patientDeleteSuccess)));
        _controller.loadPatients();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.patientDeleteFailed)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Scaffold(
        body: Stack(
          children: [
            const AppBackground(),
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
                            onPressed: () async {
                              final created = await context.push<bool>('/patients/create');
                              if (!mounted) return;
                              if (created == true) {
                                _controller.loadPatients();
                              }
                            },
                            icon: const FaIcon(FontAwesomeIcons.userPlus, size: 16),
                            label: Text(l10n.patientListAddNew),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: _controller.loading ? null : _controller.loadPatients,
                            icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
                            label: Text(l10n.patientListRefresh),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller.searchController,
                      onChanged: _controller.onSearchChanged,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.homeSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.searchController.text.isEmpty
                            ? null
                            : IconButton(onPressed: _controller.clearSearch, icon: const Icon(Icons.close)),
                        filled: true,
                        fillColor: scheme.surface.withValues(alpha: 0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _controller.loading
                          ? const Center(child: CircularProgressIndicator())
                          : _controller.error != null
                          ? Center(
                              child: Text(
                                _controller.error == 'no_clinic' ? l10n.patientClinicRequired : l10n.loginNetworkError,
                                style: TextStyle(color: scheme.error),
                              ),
                            )
                          : _controller.patients.isEmpty
                          ? Center(
                              child: Text(
                                l10n.homePatientSearchEmpty,
                                style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _controller.loadPatients,
                              child: FocusableActionDetector(
                                focusNode: _controller.listFocusNode,
                                autofocus: true,
                                shortcuts: const {
                                  SingleActivator(LogicalKeyboardKey.arrowDown): _ScrollByIntent(64),
                                  SingleActivator(LogicalKeyboardKey.arrowUp): _ScrollByIntent(-64),
                                  SingleActivator(LogicalKeyboardKey.pageDown): _ScrollByIntent(320),
                                  SingleActivator(LogicalKeyboardKey.pageUp): _ScrollByIntent(-320),
                                  SingleActivator(LogicalKeyboardKey.home): _ScrollToIntent(true),
                                  SingleActivator(LogicalKeyboardKey.end): _ScrollToIntent(false),
                                },
                                actions: {
                                  _ScrollByIntent: CallbackAction<_ScrollByIntent>(
                                    onInvoke: (intent) {
                                      if (!_controller.listController.hasClients) return null;
                                      _controller.listController.animateTo(
                                        (_controller.listController.offset + intent.delta).clamp(
                                          0.0,
                                          _controller.listController.position.maxScrollExtent,
                                        ),
                                        duration: const Duration(milliseconds: 120),
                                        curve: Curves.easeOut,
                                      );
                                      return null;
                                    },
                                  ),
                                  _ScrollToIntent: CallbackAction<_ScrollToIntent>(
                                    onInvoke: (intent) {
                                      if (!_controller.listController.hasClients) return null;
                                      _controller.listController.animateTo(
                                        intent.toTop ? 0 : _controller.listController.position.maxScrollExtent,
                                        duration: const Duration(milliseconds: 150),
                                        curve: Curves.easeOut,
                                      );
                                      return null;
                                    },
                                  ),
                                },
                                child: PatientListView(
                                  controller: _controller.listController,
                                  patients: _controller.patients,
                                  scheme: scheme,
                                  l10n: l10n,
                                  pickerMode: widget.pickerMode,
                                  onSelect: widget.pickerMode ? (patient) => context.pop(patient) : null,
                                  onUpdate: _handleUpdate,
                                  onDelete: _handleDelete,
                                ),
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}

class _ScrollByIntent extends Intent {
  const _ScrollByIntent(this.delta);

  final double delta;
}

class _ScrollToIntent extends Intent {
  const _ScrollToIntent(this.toTop);

  final bool toTop;
}
