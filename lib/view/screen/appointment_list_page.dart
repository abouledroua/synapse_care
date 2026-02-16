import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../widget/app_background.dart';
import '../widget/app_footer.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _appointments = <Map<String, dynamic>>[];
  _FilterMode _filterMode = _FilterMode.date;
  DateTime? _selectedDate;
  DateTime? _periodStart;
  DateTime? _periodEnd;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDate = DateTime(today.year, today.month, today.day);
  }

  List<Map<String, dynamic>> get _filteredAppointments {
    final query = _searchController.text.trim().toLowerCase();
    return _appointments.where((item) {
      final date = _appointmentDate(item);
      if (_filterMode == _FilterMode.date && _selectedDate != null) {
        if (date == null || !_isSameDay(date, _selectedDate!)) return false;
      }
      if (_filterMode == _FilterMode.period && (_periodStart != null || _periodEnd != null)) {
        if (date == null) return false;
        final start = _periodStart != null
            ? DateTime(_periodStart!.year, _periodStart!.month, _periodStart!.day)
            : null;
        final end = _periodEnd != null
            ? DateTime(_periodEnd!.year, _periodEnd!.month, _periodEnd!.day, 23, 59, 59)
            : null;
        if (start != null && date.isBefore(start)) return false;
        if (end != null && date.isAfter(end)) return false;
      }
      if (query.isEmpty) return true;
      final haystack = [
        '${item['num_rdv'] ?? ''}',
        '${item['motif_rdv'] ?? ''}',
        '${item['nom_patient'] ?? ''}',
        '${item['prenom_patient'] ?? ''}',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _loading = false);
  }

  DateTime? _appointmentDate(Map<String, dynamic> item) {
    final raw = item['date_rdv'] ?? item['date'] ?? item['date_rendez_vous'];
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw.toString());
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickSelectedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _filterMode = _FilterMode.date;
      _selectedDate = picked;
    });
  }

  Future<void> _pickPeriodStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodStart ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _filterMode = _FilterMode.period;
      _periodStart = picked;
      if (_periodEnd != null && _periodEnd!.isBefore(picked)) {
        _periodEnd = picked;
      }
    });
  }

  Future<void> _pickPeriodEnd() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodEnd ?? _periodStart ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _filterMode = _FilterMode.period;
      _periodEnd = picked;
      if (_periodStart != null && _periodStart!.isAfter(picked)) {
        _periodStart = picked;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final filteredAppointments = _filteredAppointments;

    return Scaffold(
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
                  IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), color: scheme.primary),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      l10n.homeMenuRdvList,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.homeMenuRdvTake),
                        ),
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _refresh,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.patientListRefresh),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.homeSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: scheme.surface.withValues(alpha: 0.9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<_FilterMode>(
                          value: _filterMode,
                          decoration: InputDecoration(
                            labelText: 'Filter',
                            filled: true,
                            fillColor: scheme.surface.withValues(alpha: 0.9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: const [
                            DropdownMenuItem(value: _FilterMode.date, child: Text('Date')),
                            DropdownMenuItem(value: _FilterMode.period, child: Text('Periode')),
                            DropdownMenuItem(value: _FilterMode.all, child: Text('All')),
                          ],
                          onChanged: (mode) {
                            if (mode == null) return;
                            setState(() {
                              _filterMode = mode;
                              if (_filterMode == _FilterMode.date && _selectedDate == null) {
                                final today = DateTime.now();
                                _selectedDate = DateTime(today.year, today.month, today.day);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_filterMode == _FilterMode.date)
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickSelectedDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_formatDate(_selectedDate)),
                        ),
                      ],
                    ),
                  if (_filterMode == _FilterMode.period)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickPeriodStart,
                          icon: const Icon(Icons.calendar_month),
                          label: Text('From: ${_formatDate(_periodStart)}'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickPeriodEnd,
                          icon: const Icon(Icons.calendar_month),
                          label: Text('To: ${_formatDate(_periodEnd)}'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredAppointments.isEmpty
                        ? Center(
                            child: Text(
                              l10n.homePatientSearchEmpty,
                              style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.separated(
                              itemCount: filteredAppointments.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = filteredAppointments[index];
                                return Card(
                                  child: ListTile(
                                    title: Text('${item['num_rdv'] ?? '-'} • ${_formatDate(_appointmentDate(item))}'),
                                    subtitle: Text('${item['motif_rdv'] ?? '-'}'),
                                  ),
                                );
                              },
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
    _searchController.dispose();
    super.dispose();
  }
}

enum _FilterMode { date, period, all }
