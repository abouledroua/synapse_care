import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/patient_service.dart';
import '../widget/patient_list_view.dart';
import '../widget/synapse_background.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final PatientService _service = PatientService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listController = ScrollController();
  final FocusNode _listFocusNode = FocusNode();
  Timer? _searchDebounce;
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _loadPatients();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _listFocusNode.requestFocus();
      }
    });
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
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        _loadPatients();
      } else {
        _searchPatients(query);
      }
    });
  }

  Future<void> _searchPatients(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _patients = await _service.searchPatients(query);
    } catch (_) {
      _error = 'network';
      _patients = [];
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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
                          onPressed: () async {
                            final created = await context.push<bool>('/patients/create');
                            if (created == true) {
                              _loadPatients();
                            }
                          },
                          icon: const FaIcon(FontAwesomeIcons.userPlus, size: 16),
                          label: Text(l10n.patientListAddNew),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _loadPatients,
                          icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
                          label: Text(l10n.patientListRefresh),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.homeSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _loadPatients();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: scheme.surface.withValues(alpha: 0.9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
                        : RefreshIndicator(
                            onRefresh: _loadPatients,
                            child: FocusableActionDetector(
                              focusNode: _listFocusNode,
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
                                    if (!_listController.hasClients) return null;
                                    _listController.animateTo(
                                      (_listController.offset + intent.delta)
                                          .clamp(0.0, _listController.position.maxScrollExtent),
                                      duration: const Duration(milliseconds: 120),
                                      curve: Curves.easeOut,
                                    );
                                    return null;
                                  },
                                ),
                                _ScrollToIntent: CallbackAction<_ScrollToIntent>(
                                  onInvoke: (intent) {
                                    if (!_listController.hasClients) return null;
                                    _listController.animateTo(
                                      intent.toTop ? 0 : _listController.position.maxScrollExtent,
                                      duration: const Duration(milliseconds: 150),
                                      curve: Curves.easeOut,
                                    );
                                    return null;
                                  },
                                ),
                              },
                              child: PatientListView(
                                controller: _listController,
                                patients: _patients,
                                scheme: scheme,
                                l10n: l10n,
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
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _listController.dispose();
    _listFocusNode.dispose();
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
