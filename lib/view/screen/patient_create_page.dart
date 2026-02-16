import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constant/layout_constants.dart';
import '../../controller/patient_create_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/app_background.dart';
import '../widget/app_footer.dart';
import '../widget/patient_create_fields.dart';

class PatientCreatePage extends StatefulWidget {
  const PatientCreatePage({super.key, this.patient});

  final Map<String, dynamic>? patient;

  @override
  State<PatientCreatePage> createState() => _PatientCreatePageState();
}

class _PatientCreatePageState extends State<PatientCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = PatientCreateController();
  final _ninFocusNode = FocusNode();
  final _nssFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.initialize(patient: widget.patient);
    _ninFocusNode.addListener(_onNinFocusChanged);
    _nssFocusNode.addListener(_onNssFocusChanged);
  }

  @override
  void dispose() {
    _ninFocusNode.removeListener(_onNinFocusChanged);
    _nssFocusNode.removeListener(_onNssFocusChanged);
    _ninFocusNode.dispose();
    _nssFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onNinFocusChanged() {
    if (_ninFocusNode.hasFocus) return;
    _checkIdentityAndPromptImport(editedField: 'nin');
  }

  void _onNssFocusChanged() {
    if (_nssFocusNode.hasFocus) return;
    _checkIdentityAndPromptImport(editedField: 'nss');
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
    final result = await _controller.submitWithResult();
    if (!mounted) return;
    if (result == PatientSubmitResult.success) {
      final message = _controller.isEditing
          ? l10n.patientEditSuccess
          : (_controller.lastCreateLinked ? l10n.patientCreateLinked : l10n.patientCreateSuccess);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      context.pop(true);
    } else {
      if (result == PatientSubmitResult.patientExists) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.patientLinkTitle),
            content: Text(l10n.patientLinkBody),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.patientLinkCancel)),
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
      final message = result == PatientSubmitResult.noClinic
          ? l10n.patientClinicRequired
          : (_controller.isEditing ? l10n.patientEditFailed : l10n.patientCreateFailed);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _checkIdentityAndPromptImport({required String editedField}) async {
    final l10n = AppLocalizations.of(context)!;
    final status = await _controller.checkExistingIdentityInClinic();
    if (!mounted) return;
    if (status == 'exists') {
      final patient = _controller.existingPatientData ?? const <String, dynamic>{};
      final fullName = '${patient['nom'] ?? ''} ${patient['prenom'] ?? ''}'.trim();
      final nin = '${patient['nin'] ?? ''}'.trim();
      final nss = '${patient['nss'] ?? ''}'.trim();
      final phone = '${patient['tel1'] ?? ''}'.trim();
      final photoUrl = _controller.existingPatientPhotoUrl();
      final rawBirthDate = '${patient['date_naissance'] ?? ''}'.trim();
      final parsedBirthDate = DateTime.tryParse(rawBirthDate);
      final birthDate = parsedBirthDate == null
          ? rawBirthDate
          : DateFormat('yyyy-MM-dd').format(parsedBirthDate.toLocal());
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.patientLinkTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person_outline) : null,
                ),
              ),
              const SizedBox(height: 10),
              Text(l10n.patientLinkBody),
              const SizedBox(height: 10),
              if (fullName.isNotEmpty) Text('${l10n.patientHeaderFullName}: $fullName'),
              if (nin.isNotEmpty) Text('${l10n.patientHeaderNin}: $nin'),
              if (nss.isNotEmpty) Text('${l10n.patientHeaderNss}: $nss'),
              if (phone.isNotEmpty) Text('${l10n.patientHeaderPhone}: $phone'),
              if (birthDate.isNotEmpty) Text('${l10n.patientFieldDateNaissance}: $birthDate'),
            ],
          ),
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
        if (linked) context.pop(true);
      }
      if (confirmed == false) {
        if (editedField == 'nin') {
          _controller.nin.clear();
        } else if (editedField == 'nss') {
          _controller.nss.clear();
        }
      }
      return;
    }
    if (status == 'already_linked') {
      if (editedField == 'nin') {
        _controller.nin.clear();
      } else if (editedField == 'nss') {
        _controller.nss.clear();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.patientIdentityExistsInClinic)),
      );
      return;
    }
    if (status == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginNetworkError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final avatarImage = _controller.photoProvider();
        return Scaffold(
        bottomNavigationBar: const AppFooter(),
        body: Stack(
          children: [
            const AppBackground(showFooter: false),
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
                            onPressed: _controller.saving ? null : () => context.pop(),
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
                          if (_controller.saving) ...[const LinearProgressIndicator(), const SizedBox(height: 10)],
                          Expanded(
                            child: IgnorePointer(
                              ignoring: _controller.saving,
                              child: Scrollbar(
                                controller: _controller.formScrollController,
                                thumbVisibility: kIsWeb ? true : null,
                                thickness: kIsWeb ? 6 : null,
                                radius: kIsWeb ? const Radius.circular(8) : null,
                                trackVisibility: kIsWeb ? true : null,
                                interactive: kIsWeb ? true : null,
                                child: ListView(
                                  controller: _controller.formScrollController,
                                  padding: const EdgeInsets.only(bottom: 12),
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
                                              backgroundImage: avatarImage,
                                              child: avatarImage == null
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
                                      builder: (context, constraints) => Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: PatientCountryField(
                                              label: l10n.patientFieldNationality,
                                              controller: _controller.nationalite,
                                              onSelectCountry: _controller.setNationaliteCountry,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 2,
                                            child: PatientDropdownIntField(
                                              label: l10n.patientFieldSexe,
                                              value: _controller.sexe,
                                              options: {1: l10n.patientSexMale, 2: l10n.patientSexFemale},
                                              onChanged: _controller.setSexe,
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
                                        child: PatientTextField(
                                          label: l10n.patientFieldNin,
                                          controller: _controller.nin,
                                          l10n: l10n,
                                          requiredValidator: _controller.requiredValidator,
                                          required: false,
                                          focusNode: _ninFocusNode,
                                          textInputAction: TextInputAction.next,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: PatientTextField(
                                          label: l10n.patientFieldNss,
                                          controller: _controller.nss,
                                          l10n: l10n,
                                          requiredValidator: _controller.requiredValidator,
                                          required: false,
                                          focusNode: _nssFocusNode,
                                          textInputAction: TextInputAction.next,
                                        ),
                                      ),
                                    ],
                                  ),
                                    LayoutBuilder(
                                      builder: (context, constraints) =>
                                          (constraints.maxWidth < LayoutConstants.wideBreakpoint)
                                          ? Column(
                                              children: [
                                                PatientTextField(
                                                  label: l10n.patientFieldNom,
                                                  controller: _controller.nom,
                                                  l10n: l10n,
                                                  requiredValidator: _controller.requiredValidator,
                                                  required: true,
                                                ),
                                                PatientTextField(
                                                  label: l10n.patientFieldPrenom,
                                                  controller: _controller.prenom,
                                                  l10n: l10n,
                                                  requiredValidator: _controller.requiredValidator,
                                                  required: true,
                                                  textCapitalization: TextCapitalization.characters,
                                                  inputFormatters: [UpperCaseTextFormatter()],
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: PatientTextField(
                                                    label: l10n.patientFieldNom,
                                                    controller: _controller.nom,
                                                    l10n: l10n,
                                                    requiredValidator: _controller.requiredValidator,
                                                    required: true,
                                                    textCapitalization: TextCapitalization.characters,
                                                    inputFormatters: [UpperCaseTextFormatter()],
                                                  ),
                                                ),
                                                const SizedBox(width: 30),
                                                Expanded(
                                                  child: PatientTextField(
                                                    label: l10n.patientFieldPrenom,
                                                    controller: _controller.prenom,
                                                    l10n: l10n,
                                                    requiredValidator: _controller.requiredValidator,
                                                    required: true,
                                                    textCapitalization: TextCapitalization.characters,
                                                    inputFormatters: [UpperCaseTextFormatter()],
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                    LayoutBuilder(
                                      builder: (context, constraints) =>
                                          (constraints.maxWidth >= LayoutConstants.wideBreakpoint)
                                          ? Row(
                                              children: [
                                                SizedBox(
                                                  width: 160,
                                                  child: PatientDateField(
                                                    label: l10n.patientFieldDateNaissance,
                                                    controller: _controller.dateNaissance,
                                                    l10n: l10n,
                                                    requiredValidator: _controller.requiredValidator,
                                                    onTap: _pickDate,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 110,
                                                  child: PatientCheckboxField(
                                                    label: l10n.patientFieldPresume,
                                                    value: _controller.presume == 1,
                                                    onChanged: (value) => _controller.setPresume(value == true),
                                                    trueLabel: l10n.patientOptionYes,
                                                    falseLabel: l10n.patientOptionNo,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                SizedBox(
                                                  width: 80,
                                                  child: PatientTextField(
                                                    label: l10n.patientFieldAge,
                                                    controller: _controller.age,
                                                    l10n: l10n,
                                                    requiredValidator: _controller.requiredValidator,
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
                                                  child: PatientDropdownIntField(
                                                    label: l10n.patientFieldTypeAge,
                                                    value: _controller.typeAge,
                                                    options: {
                                                      1: l10n.patientAgeYears,
                                                      2: l10n.patientAgeMonths,
                                                      3: l10n.patientAgeDays,
                                                    },
                                                    onChanged: _controller.setTypeAge,
                                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: PatientTextField(
                                                    label: l10n.patientFieldLieuNaissance,
                                                    controller: _controller.lieuNaissance,
                                                    l10n: l10n,
                                                    requiredValidator: _controller.requiredValidator,
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
                                                      child: PatientDateField(
                                                        label: l10n.patientFieldDateNaissance,
                                                        controller: _controller.dateNaissance,
                                                        l10n: l10n,
                                                        requiredValidator: _controller.requiredValidator,
                                                        onTap: _pickDate,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    SizedBox(
                                                      width: 130,
                                                      child: PatientCheckboxField(
                                                        label: l10n.patientFieldPresume,
                                                        value: _controller.presume == 1,
                                                        onChanged: (value) => _controller.setPresume(value == true),
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
                                                      child: PatientTextField(
                                                        label: l10n.patientFieldAge,
                                                        controller: _controller.age,
                                                        l10n: l10n,
                                                        requiredValidator: _controller.requiredValidator,
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
                                                      child: PatientDropdownIntField(
                                                        label: l10n.patientFieldTypeAge,
                                                        value: _controller.typeAge,
                                                        options: {
                                                          1: l10n.patientAgeYears,
                                                          2: l10n.patientAgeMonths,
                                                          3: l10n.patientAgeDays,
                                                        },
                                                        onChanged: _controller.setTypeAge,
                                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                PatientTextField(
                                                  label: l10n.patientFieldLieuNaissance,
                                                  controller: _controller.lieuNaissance,
                                                  l10n: l10n,
                                                  requiredValidator: _controller.requiredValidator,
                                                  required: false,
                                                ),
                                              ],
                                            ),
                                    ),
                                    PatientPhoneField(
                                      label: l10n.patientFieldTel1,
                                      controller: _controller.tel1,
                                      l10n: l10n,
                                      scheme: scheme,
                                      countryCode: _controller.phoneCountryCode1,
                                      phoneValidator: _controller.phoneValidator,
                                      phoneFieldValue: _controller.phoneFieldValue,
                                    ),
                                    PatientPhoneField(
                                      label: l10n.patientFieldTel2,
                                      controller: _controller.tel2,
                                      l10n: l10n,
                                      scheme: scheme,
                                      countryCode: _controller.phoneCountryCode2,
                                      phoneValidator: _controller.phoneValidator,
                                      phoneFieldValue: _controller.phoneFieldValue,
                                    ),
                                    PatientDropdownIntField(
                                      label: l10n.patientFieldGs,
                                      value: _controller.gs,
                                      options: const {
                                        1: 'A+',
                                        2: 'A-',
                                        3: 'B+',
                                        4: 'B-',
                                        5: 'AB+',
                                        6: 'AB-',
                                        7: 'O+',
                                        8: 'O-',
                                      },
                                      onChanged: _controller.setGs,
                                      hintText: l10n.patientFieldGs,
                                    ),
                                    PatientTextField(
                                      label: l10n.patientFieldAdresse,
                                      controller: _controller.adresse,
                                      l10n: l10n,
                                      requiredValidator: _controller.requiredValidator,
                                      required: false,
                                    ),
                                    PatientTextField(
                                      label: l10n.patientFieldProfession,
                                      controller: _controller.profession,
                                      l10n: l10n,
                                      requiredValidator: _controller.requiredValidator,
                                      required: false,
                                    ),
                                    PatientTextField(
                                      label: l10n.patientFieldEmail,
                                      controller: _controller.email,
                                      l10n: l10n,
                                      requiredValidator: _controller.requiredValidator,
                                      required: false,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 130,
                                          child: PatientCheckboxField(
                                            label: l10n.patientFieldConventionne,
                                            value: _controller.conventionne == 1,
                                            onChanged: (value) => _controller.setConventionne(value == true),
                                            trueLabel: l10n.patientOptionYes,
                                            falseLabel: l10n.patientOptionNo,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        if (_controller.conventionne == 1)
                                          Expanded(
                                            child: PatientTextField(
                                              label: l10n.patientFieldPourcConv,
                                              controller: _controller.pourcConv,
                                              l10n: l10n,
                                              requiredValidator: _controller.requiredValidator,
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
                                      child: _controller.saving
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : Text(l10n.patientCreateSubmit),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
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
            ),
          ],
        ),
      );
      },
    );
  }
}
