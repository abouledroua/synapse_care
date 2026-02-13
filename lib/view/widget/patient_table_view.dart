import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';
import '../../core/utils/patient_formatters.dart';
import '../../l10n/app_localizations.dart';

class PatientTableView extends StatefulWidget {
  const PatientTableView({
    super.key,
    required this.patients,
    required this.scheme,
    required this.l10n,
    required this.onUpdate,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> patients;
  final ColorScheme scheme;
  final AppLocalizations l10n;
  final ValueChanged<Map<String, dynamic>> onUpdate;
  final ValueChanged<Map<String, dynamic>> onDelete;

  @override
  State<PatientTableView> createState() => _PatientTableViewState();
}

class _PatientTableViewState extends State<PatientTableView> {
  static const double _headingRowHeight = 48;
  static const double _dataRowHeight = 52;
  static const double _actionColumnWidth = 92;
  static const List<double> _columnWidths = [180, 80, 110, 110, 80, 140, 200, 160, 90, 120];

  late final ScrollController _verticalController;
  late final ScrollController _fixedController;
  late final ScrollController _horizontalController;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
    _fixedController = ScrollController();
    _horizontalController = ScrollController();

    _verticalController.addListener(() {
      if (_syncing || !_fixedController.hasClients) return;
      _syncing = true;
      _fixedController.jumpTo(_verticalController.position.pixels);
      _syncing = false;
    });

    _fixedController.addListener(() {
      if (_syncing || !_verticalController.hasClients) return;
      _syncing = true;
      _verticalController.jumpTo(_fixedController.position.pixels);
      _syncing = false;
    });
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _fixedController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(text, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _dataCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(text, overflow: TextOverflow.ellipsis),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      widget.l10n.patientHeaderFullName,
      widget.l10n.patientHeaderSexe,
      widget.l10n.patientHeaderNin,
      widget.l10n.patientHeaderNss,
      widget.l10n.patientHeaderAge,
      widget.l10n.patientHeaderPhone,
      widget.l10n.patientHeaderEmail,
      widget.l10n.patientHeaderAddress,
      widget.l10n.patientHeaderDebt,
      widget.l10n.patientHeaderBloodGroup,
    ];
    final columns = List.generate(
      labels.length,
      (index) => DataColumn(label: _headerCell(labels[index], _columnWidths[index])),
    );

    return LayoutBuilder(
      builder: (context, constraints) => ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(true),
          thickness: WidgetStateProperty.all(10),
          radius: const Radius.circular(8),
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => widget.scheme.primary.withValues(alpha: states.contains(WidgetState.dragged) ? 0.9 : 0.65),
          ),
          trackColor: WidgetStateProperty.all(widget.scheme.primary.withValues(alpha: 0.15)),
          trackBorderColor: WidgetStateProperty.all(widget.scheme.primary.withValues(alpha: 0.25)),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.scheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
          ),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Row(
              children: [
                Expanded(
                  child: RawScrollbar(
                    controller: _horizontalController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: 10,
                    radius: const Radius.circular(8),
                    thumbColor: widget.scheme.primary.withValues(alpha: 0.65),
                    trackColor: widget.scheme.primary.withValues(alpha: 0.15),
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    notificationPredicate: (notification) => notification.metrics.axis == Axis.horizontal,
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth - _actionColumnWidth),
                        child: Column(
                          children: [
                            DataTable(
                              headingRowColor: WidgetStateProperty.all(widget.scheme.primary.withValues(alpha: 0.08)),
                              headingRowHeight: _headingRowHeight,
                              dataRowMinHeight: 0,
                              dataRowMaxHeight: 0,
                              columnSpacing: 0,
                              horizontalMargin: 0,
                              columns: columns,
                              rows: const [],
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: (constraints.maxHeight - _headingRowHeight - 4).clamp(0.0, double.infinity),
                              child: Scrollbar(
                                controller: _verticalController,
                                thumbVisibility: true,
                                notificationPredicate: (notification) => notification.metrics.axis == Axis.vertical,
                                child: SingleChildScrollView(
                                  controller: _verticalController,
                                  child: DataTable(
                                    headingRowHeight: 0,
                                    dataRowMinHeight: _dataRowHeight,
                                    dataRowMaxHeight: _dataRowHeight,
                                    columnSpacing: 0,
                                    horizontalMargin: 0,
                                    columns: columns,
                                    rows: widget.patients.map((item) {
                                      final nom = (item['nom'] ?? '').toString();
                                      final prenom = (item['prenom'] ?? '').toString();
                                      final displayName = '${prenom.isEmpty ? '' : '$prenom '}$nom'.trim();
                                      final sexe = PatientFormatters.formatSexe(
                                        item['sexe'],
                                        maleLabel: widget.l10n.patientSexMale,
                                        femaleLabel: widget.l10n.patientSexFemale,
                                      );
                                      final nin = (item['nin'] ?? '').toString();
                                      final nss = (item['nss'] ?? '').toString();
                                      final age = PatientFormatters.formatAge(
                                        item['age'],
                                        item['type_age'],
                                        yearsLabel: widget.l10n.patientAgeYears,
                                        monthsLabel: widget.l10n.patientAgeMonths,
                                        daysLabel: widget.l10n.patientAgeDays,
                                      );
                                      final tel = PatientFormatters.formatPhone(item['tel1']);
                                      final email = (item['email'] ?? '').toString();
                                      final adresse = (item['adresse'] ?? '').toString();
                                      final rawCurrency =
                                          (AuthController.globalClinic?['default_currency'] ?? '').toString().trim();
                                      final currency =
                                          rawCurrency.isNotEmpty ? rawCurrency : widget.l10n.patientCurrencyDzdLatin;
                                      final dette = PatientFormatters.formatDebt(
                                        item['dette'],
                                        localeName: widget.l10n.localeName,
                                        currencyLatin: currency,
                                        currencyArabic: currency,
                                      );
                                      final gs = PatientFormatters.formatGs(item['gs']);
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            _dataCell(
                                              displayName.isEmpty ? widget.l10n.homePatientSearchUnnamed : displayName,
                                              _columnWidths[0],
                                            ),
                                          ),
                                          DataCell(_dataCell(sexe, _columnWidths[1])),
                                          DataCell(_dataCell(nin, _columnWidths[2])),
                                          DataCell(_dataCell(nss, _columnWidths[3])),
                                          DataCell(_dataCell(age, _columnWidths[4])),
                                          DataCell(_dataCell(tel, _columnWidths[5])),
                                          DataCell(_dataCell(email, _columnWidths[6])),
                                          DataCell(_dataCell(adresse, _columnWidths[7])),
                                          DataCell(_dataCell(dette, _columnWidths[8])),
                                          DataCell(_dataCell(gs, _columnWidths[9])),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: _actionColumnWidth,
                  child: Column(
                    children: [
                      Container(
                        height: _headingRowHeight,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: widget.scheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.l10n.patientHeaderActions,
                          style: TextStyle(color: widget.scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _fixedController,
                          child: Column(
                            children: widget.patients.map((item) {
                              return SizedBox(
                                height: _dataRowHeight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () => widget.onUpdate(item),
                                      icon: Icon(Icons.edit_outlined, color: widget.scheme.primary),
                                      tooltip: widget.l10n.patientActionUpdate,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    IconButton(
                                      onPressed: () => widget.onDelete(item),
                                      icon: Icon(Icons.delete_outline, color: widget.scheme.error),
                                      tooltip: widget.l10n.patientActionDelete,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
