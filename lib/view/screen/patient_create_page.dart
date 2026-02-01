import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../services/patient_service.dart';
import '../widget/synapse_background.dart';

class PatientCreatePage extends StatefulWidget {
  const PatientCreatePage({super.key});

  @override
  State<PatientCreatePage> createState() => _PatientCreatePageState();
}

class _PatientCreatePageState extends State<PatientCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _service = PatientService();

  final _codeBarre = TextEditingController();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _dateNaissance = TextEditingController();
  final _email = TextEditingController();
  final _age = TextEditingController();
  final _tel1 = TextEditingController();
  final _tel2 = TextEditingController();
  final _wilaya = TextEditingController();
  final _apc = TextEditingController();
  final _adresse = TextEditingController();
  final _dette = TextEditingController();
  final _pourcConv = TextEditingController();
  final _lieuNaissance = TextEditingController();
  final _profession = TextEditingController();
  final _diagnostique = TextEditingController();
  final _nin = TextEditingController();
  final _nss = TextEditingController();
  final _nbImpression = TextEditingController();
  final _codeMalade = TextEditingController();
  final _photoUrl = TextEditingController();

  DateTime? _birthDate;
  int _sexe = 1;
  int _typeAge = 1;
  int _gs = 1;
  int _presume = 0;
  int _conventionne = 0;
  bool _saving = false;

  @override
  void dispose() {
    _codeBarre.dispose();
    _nom.dispose();
    _prenom.dispose();
    _dateNaissance.dispose();
    _email.dispose();
    _age.dispose();
    _tel1.dispose();
    _tel2.dispose();
    _wilaya.dispose();
    _apc.dispose();
    _adresse.dispose();
    _dette.dispose();
    _pourcConv.dispose();
    _lieuNaissance.dispose();
    _profession.dispose();
    _diagnostique.dispose();
    _nin.dispose();
    _nss.dispose();
    _nbImpression.dispose();
    _codeMalade.dispose();
    _photoUrl.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.fieldRequired;
    return null;
  }

  String? _intValidator(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.fieldRequired;
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return l10n.fieldInvalidNumber;
    return null;
  }

  String? _doubleValidator(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.fieldRequired;
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) return l10n.fieldInvalidNumber;
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _dateNaissance.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final payload = <String, dynamic>{
        'code_barre': _codeBarre.text.trim(),
        'nom': _nom.text.trim(),
        'prenom': _prenom.text.trim(),
        'date_naissance': _dateNaissance.text.trim(),
        'email': _email.text.trim(),
        'age': int.parse(_age.text.trim()),
        'tel1': _tel1.text.trim(),
        'wilaya': int.parse(_wilaya.text.trim()),
        'apc': int.parse(_apc.text.trim()),
        'adresse': _adresse.text.trim(),
        'dette': double.parse(_dette.text.trim().replaceAll(',', '.')),
        'presume': _presume,
        'sexe': _sexe,
        'type_age': _typeAge,
        'conventionne': _conventionne,
        'pourc_conv': double.parse(_pourcConv.text.trim().replaceAll(',', '.')),
        'lieu_naissance': _lieuNaissance.text.trim(),
        'gs': _gs,
        'profession': _profession.text.trim(),
        'diagnostique': _diagnostique.text.trim(),
        'tel2': _tel2.text.trim(),
        'nin': _nin.text.trim(),
        'nss': _nss.text.trim(),
        'nb_impression': int.parse(_nbImpression.text.trim()),
        'code_malade': _codeMalade.text.trim(),
        'photo_url': _photoUrl.text.trim(),
      };
      await _service.createPatient(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.patientCreateSuccess)));
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.patientCreateFailed)));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600);

    return Scaffold(
      body: Stack(
        children: [
          const SynapseBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
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
                        l10n.patientCreateTitle,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          _sectionTitle(l10n.patientSectionIdentity, titleStyle),
                          _textField(l10n.patientFieldCodeBarre, _codeBarre, l10n),
                          _textField(l10n.patientFieldNom, _nom, l10n),
                          _textField(l10n.patientFieldPrenom, _prenom, l10n),
                          _dateField(l10n.patientFieldDateNaissance, _dateNaissance, l10n),
                          _dropdownInt(l10n.patientFieldSexe, _sexe, {
                            1: l10n.patientSexMale,
                            2: l10n.patientSexFemale,
                          }, (value) => setState(() => _sexe = value)),
                          _dropdownInt(l10n.patientFieldTypeAge, _typeAge, {
                            1: l10n.patientAgeYears,
                            2: l10n.patientAgeMonths,
                            3: l10n.patientAgeDays,
                          }, (value) => setState(() => _typeAge = value)),
                          _dropdownInt(l10n.patientFieldGs, _gs, const {
                            1: 'A+',
                            2: 'A-',
                            3: 'B+',
                            4: 'B-',
                            5: 'AB+',
                            6: 'AB-',
                            7: 'O+',
                            8: 'O-',
                          }, (value) => setState(() => _gs = value)),
                          _textField(l10n.patientFieldAge, _age, l10n, isNumber: true, validator: _intValidator),
                          _textField(l10n.patientFieldLieuNaissance, _lieuNaissance, l10n),
                          _textField(l10n.patientFieldProfession, _profession, l10n),
                          _textField(l10n.patientFieldDiagnostique, _diagnostique, l10n, maxLines: 3),
                          const SizedBox(height: 12),
                          _sectionTitle(l10n.patientSectionContact, titleStyle),
                          _textField(l10n.patientFieldTel1, _tel1, l10n),
                          _textField(l10n.patientFieldTel2, _tel2, l10n),
                          _textField(l10n.patientFieldEmail, _email, l10n),
                          _textField(l10n.patientFieldAdresse, _adresse, l10n),
                          _textField(l10n.patientFieldWilaya, _wilaya, l10n, isNumber: true, validator: _intValidator),
                          _textField(l10n.patientFieldApc, _apc, l10n, isNumber: true, validator: _intValidator),
                          const SizedBox(height: 12),
                          _sectionTitle(l10n.patientSectionInsurance, titleStyle),
                          _dropdownInt(l10n.patientFieldPresume, _presume, {
                            1: l10n.patientOptionYes,
                            0: l10n.patientOptionNo,
                          }, (value) => setState(() => _presume = value)),
                          _dropdownInt(l10n.patientFieldConventionne, _conventionne, {
                            1: l10n.patientOptionYes,
                            0: l10n.patientOptionNo,
                          }, (value) => setState(() => _conventionne = value)),
                          _textField(
                            l10n.patientFieldPourcConv,
                            _pourcConv,
                            l10n,
                            isNumber: true,
                            validator: _doubleValidator,
                          ),
                          _textField(l10n.patientFieldDette, _dette, l10n, isNumber: true, validator: _doubleValidator),
                          _textField(l10n.patientFieldNin, _nin, l10n),
                          _textField(l10n.patientFieldNss, _nss, l10n),
                          _textField(
                            l10n.patientFieldNbImpression,
                            _nbImpression,
                            l10n,
                            isNumber: true,
                            validator: _intValidator,
                          ),
                          _textField(l10n.patientFieldCodeMalade, _codeMalade, l10n),
                          _textField(l10n.patientFieldPhotoUrl, _photoUrl, l10n),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _saving ? null : _save,
                            child: Text(_saving ? l10n.patientCreateSaving : l10n.patientCreateSubmit),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text, style: style),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller,
    AppLocalizations l10n, {
    bool isNumber = false,
    int maxLines = 1,
    String? Function(String?, AppLocalizations)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) => (validator ?? _requiredValidator)(value, l10n),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _dateField(String label, TextEditingController controller, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: _pickDate,
        validator: (value) => _requiredValidator(value, l10n),
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _dropdownInt(String label, int value, Map<int, String> options, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        items: options.entries
            .map((entry) => DropdownMenuItem<int>(value: entry.key, child: Text(entry.value)))
            .toList(),
        onChanged: (val) {
          if (val == null) return;
          onChanged(val);
        },
      ),
    );
  }
}
