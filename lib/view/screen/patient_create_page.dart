import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_picker/country_picker.dart';

import '../../controller/auth_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../controller/patient_create_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/app_background.dart';

class PatientCreatePage extends StatefulWidget {
  const PatientCreatePage({super.key, this.patient});

  final Map<String, dynamic>? patient;

  @override
  State<PatientCreatePage> createState() => _PatientCreatePageState();
}

class _PatientCreatePageState extends State<PatientCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = PatientCreateController();

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _controller.loadFromPatient(widget.patient!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    _controller.setBirthDate(picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final ok = await _controller.submit();
    if (!mounted) return;
    if (ok) {
      final message = _controller.isEditing
          ? l10n.patientEditSuccess
          : (_controller.lastCreateLinked ? l10n.patientCreateLinked : l10n.patientCreateSuccess);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      context.pop(true);
    } else {
      if (_controller.lastError == 'patient_exists') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.patientLinkTitle),
            content: Text(l10n.patientLinkBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.patientLinkCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.patientLinkConfirm),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          final linked = await _controller.linkExistingPatient();
          if (!mounted) return;
          final message = linked ? l10n.patientLinkSuccess : l10n.patientLinkFailed;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          if (linked) {
            context.pop(true);
          }
        }
        return;
      }
      final message = _controller.lastError == 'no_clinic'
          ? l10n.patientClinicRequired
          : (_controller.isEditing ? l10n.patientEditFailed : l10n.patientCreateFailed);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    if (!_controller.isEditing && _controller.nationalite.text.trim().isEmpty) {
      final clinicDefault = AuthController.globalClinic?['nationalite_patient_defaut'];
      final phoneCode = clinicDefault is num ? clinicDefault.toInt().toString() : '$clinicDefault';
      if (phoneCode.trim().isNotEmpty) {
        _controller.setNationaliteFromPhoneCode(phoneCode.trim());
      } else {
        _controller.setNationaliteFromPhoneCode('213');
      }
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Scaffold(
        body: Stack(
          children: [
            const AppBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
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
                              _controller.isEditing ? l10n.patientEditTitle : l10n.patientCreateTitle,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Scrollbar(
                              controller: _controller.formScrollController,
                              thumbVisibility: kIsWeb ? true : null,
                              thickness: kIsWeb ? 6 : null,
                              radius: kIsWeb ? const Radius.circular(8) : null,
                              trackVisibility: kIsWeb ? true : null,
                              interactive: kIsWeb ? true : null,
                              child: ListView(
                                controller: _controller.formScrollController,
                                children: [
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        GestureDetector(
                                          onTap: _controller.pickPhoto,
                                          child: CircleAvatar(
                                            radius: 45,
                                            backgroundColor: scheme.primary.withValues(alpha: 0.15),
                                            backgroundImage: _controller.photoProvider(),
                                            child: _controller.photo == null
                                                ? Icon(
                                                    Icons.photo_camera_outlined,
                                                    size: 30,
                                                    color: scheme.primary.withValues(alpha: 0.8),
                                                  )
                                                : null,
                                          ),
                                        ),
                                        if (_controller.photo != null)
                                          GestureDetector(
                                            onTap: _controller.clearPhoto,
                                            child: Container(
                                              height: 22,
                                              width: 22,
                                              decoration: BoxDecoration(
                                                color: scheme.surface,
                                                shape: BoxShape.circle,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0x33000000),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(Icons.close, size: 14, color: scheme.primary),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  LayoutBuilder(
                                    builder: (context, constraints) =>
                                        (constraints.maxWidth < LayoutConstants.wideBreakpoint)
                                        ? Column(
                                            children: [
                                              _textField(l10n.patientFieldNom, _controller.nom, l10n, required: true),
                                              _textField(
                                                l10n.patientFieldPrenom,
                                                _controller.prenom,
                                                l10n,
                                                required: true,
                                                textCapitalization: TextCapitalization.words,
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Expanded(
                                                child: _textField(
                                                  l10n.patientFieldNom,
                                                  _controller.nom,
                                                  l10n,
                                                  required: true,
                                                  textCapitalization: TextCapitalization.characters,
                                                  inputFormatters: [UpperCaseTextFormatter()],
                                                ),
                                              ),
                                              const SizedBox(width: 30),
                                              Expanded(
                                                child: _textField(
                                                  l10n.patientFieldPrenom,
                                                  _controller.prenom,
                                                  l10n,
                                                  required: true,
                                                  textCapitalization: TextCapitalization.characters,
                                                  inputFormatters: [UpperCaseTextFormatter()],
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                  LayoutBuilder(
                                    builder: (context, constraints) => Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: _countryField(l10n.patientFieldNationality, _controller.nationalite),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 2,
                                          child: _dropdownInt(
                                            l10n.patientFieldSexe,
                                            _controller.sexe,
                                            {1: l10n.patientSexMale, 2: l10n.patientSexFemale},
                                            (value) => _controller.setSexe(value),
                                            fillColor: _controller.sexe == 1
                                                ? Colors.transparent
                                                : const Color(0xFFFFE6F0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _textField(l10n.patientFieldNin, _controller.nin, l10n, required: false),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _textField(l10n.patientFieldNss, _controller.nss, l10n, required: false),
                                      ),
                                    ],
                                  ),
                                  LayoutBuilder(
                                    builder: (context, constraints) =>
                                        (constraints.maxWidth >= LayoutConstants.wideBreakpoint)
                                        ? Row(
                                            children: [
                                              SizedBox(
                                                width: 160,
                                                child: _dateField(
                                                  l10n.patientFieldDateNaissance,
                                                  _controller.dateNaissance,
                                                  l10n,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 110,
                                                child: _checkboxField(
                                                  l10n.patientFieldPresume,
                                                  _controller.presume == 1,
                                                  (value) => _controller.setPresume(value == true),
                                                  trueLabel: l10n.patientOptionYes,
                                                  falseLabel: l10n.patientOptionNo,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              SizedBox(
                                                width: 80,
                                                child: _textField(
                                                  l10n.patientFieldAge,
                                                  _controller.age,
                                                  l10n,
                                                  isNumber: true,
                                                  validator: _controller.optionalIntValidator,
                                                  required: false,
                                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                  onChanged: (_) => _controller.syncDobFromAge(),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              SizedBox(
                                                width: 140,
                                                child: _dropdownInt(
                                                  l10n.patientFieldTypeAge,
                                                  _controller.typeAge,
                                                  {
                                                    1: l10n.patientAgeYears,
                                                    2: l10n.patientAgeMonths,
                                                    3: l10n.patientAgeDays,
                                                  },
                                                  (value) => _controller.setTypeAge(value),
                                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: _textField(
                                                  l10n.patientFieldLieuNaissance,
                                                  _controller.lieuNaissance,
                                                  l10n,
                                                  required: false,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _dateField(
                                                      l10n.patientFieldDateNaissance,
                                                      _controller.dateNaissance,
                                                      l10n,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  SizedBox(
                                                    width: 130,
                                                    child: _checkboxField(
                                                      l10n.patientFieldPresume,
                                                      _controller.presume == 1,
                                                      (value) => _controller.setPresume(value == true),
                                                      trueLabel: l10n.patientOptionYes,
                                                      falseLabel: l10n.patientOptionNo,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 100,
                                                    child: _textField(
                                                      l10n.patientFieldAge,
                                                      _controller.age,
                                                      l10n,
                                                      isNumber: true,
                                                      validator: _controller.optionalIntValidator,
                                                      required: false,
                                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                      onChanged: (_) => _controller.syncDobFromAge(),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  SizedBox(
                                                    width: 140,
                                                    child: _dropdownInt(
                                                      l10n.patientFieldTypeAge,
                                                      _controller.typeAge,
                                                      {
                                                        1: l10n.patientAgeYears,
                                                        2: l10n.patientAgeMonths,
                                                        3: l10n.patientAgeDays,
                                                      },
                                                      (value) => _controller.setTypeAge(value),
                                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              _textField(
                                                l10n.patientFieldLieuNaissance,
                                                _controller.lieuNaissance,
                                                l10n,
                                                required: false,
                                              ),
                                            ],
                                          ),
                                  ),
                                  _phoneField(
                                    l10n.patientFieldTel1,
                                    _controller.tel1,
                                    l10n,
                                    scheme,
                                    countryCode: _controller.phoneCountryCode1,
                                  ),
                                  _phoneField(
                                    l10n.patientFieldTel2,
                                    _controller.tel2,
                                    l10n,
                                    scheme,
                                    countryCode: _controller.phoneCountryCode2,
                                  ),
                                  _dropdownInt(
                                    l10n.patientFieldGs,
                                    _controller.gs,
                                    const {1: 'A+', 2: 'A-', 3: 'B+', 4: 'B-', 5: 'AB+', 6: 'AB-', 7: 'O+', 8: 'O-'},
                                    (value) => _controller.setGs(value),
                                    hintText: l10n.patientFieldGs,
                                  ),
                                  _textField(l10n.patientFieldAdresse, _controller.adresse, l10n, required: false),
                                  _textField(
                                    l10n.patientFieldProfession,
                                    _controller.profession,
                                    l10n,
                                    required: false,
                                  ),
                                  _textField(l10n.patientFieldEmail, _controller.email, l10n, required: false),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 130,
                                        child: _checkboxField(
                                          l10n.patientFieldConventionne,
                                          _controller.conventionne == 1,
                                          (value) => _controller.setConventionne(value == true),
                                          trueLabel: l10n.patientOptionYes,
                                          falseLabel: l10n.patientOptionNo,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      if (_controller.conventionne == 1)
                                        Expanded(
                                          child: _textField(
                                            l10n.patientFieldPourcConv,
                                            _controller.pourcConv,
                                            l10n,
                                            isNumber: true,
                                            validator: _controller.optionalDoubleValidator,
                                            required: false,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton(
                                    onPressed: _controller.saving ? null : _save,
                                    child: Text(
                                      _controller.saving ? l10n.patientCreateSaving : l10n.patientCreateSubmit,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller,
    AppLocalizations l10n, {
    bool isNumber = false,
    int maxLines = 1,
    bool required = true,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?, AppLocalizations)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: (value) => (validator != null)
          ? validator(value, l10n)
          : (!required)
          ? null
          : _controller.requiredValidator(value, l10n),
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  Widget _dateField(String label, TextEditingController controller, AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      readOnly: true,
      onTap: _pickDate,
      validator: (value) => _controller.requiredValidator(value, l10n),
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  Widget _phoneField(
    String label,
    TextEditingController controller,
    AppLocalizations l10n,
    ColorScheme scheme, {
    required String countryCode,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: IntlPhoneField(
      key: ValueKey('phone-$label-$countryCode'),
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      initialCountryCode: countryCode,
      initialValue: _controller.phoneFieldValue(controller.text),
      dropdownIcon: Icon(Icons.arrow_drop_down, color: scheme.primary.withValues(alpha: 0.7)),
      style: TextStyle(color: scheme.onSurfaceVariant),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (phone) => _controller.phoneValidator(phone, l10n),
      onChanged: (phone) => controller.text = phone.completeNumber,
      textInputAction: TextInputAction.next,
    ),
  );

  Widget _dropdownInt(
    String label,
    int? value,
    Map<int, String> options,
    ValueChanged<int> onChanged, {
    Color? fillColor,
    FloatingLabelBehavior? floatingLabelBehavior,
    String? hintText,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? label,
        floatingLabelBehavior: floatingLabelBehavior ?? FloatingLabelBehavior.always,
        filled: fillColor != null,
        fillColor: fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: options.entries.map((entry) => DropdownMenuItem<int>(value: entry.key, child: Text(entry.value))).toList(),
      onChanged: (val) {
        if (val == null) return;
        onChanged(val);
      },
    ),
  );

  Widget _countryField(String label, TextEditingController controller) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: () =>
          showCountryPicker(context: context, showPhoneCode: false, onSelect: _controller.setNationaliteCountry),
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          controller.text.trim().isEmpty ? label : controller.text.trim(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: controller.text.trim().isEmpty ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
      ),
    ),
  );

  Widget _checkboxField(
    String label,
    bool value,
    ValueChanged<bool?> onChanged, {
    required String trueLabel,
    required String falseLabel,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SizedBox(
      height: 56,
      child: Row(
        children: [
          Theme(
            data: Theme.of(
              context,
            ).copyWith(visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Transform.scale(
              scale: 0.85,
              child: Checkbox(value: value, onChanged: onChanged),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(!value),
              child: Ink(child: Text(label)),
            ),
          ),
        ],
      ),
    ),
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) => newValue.copyWith(
    text: newValue.text.toUpperCase(),
    selection: newValue.selection,
    composing: newValue.composing,
  );
}
