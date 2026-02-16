import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../l10n/app_localizations.dart';

class PatientTextField extends StatelessWidget {
  const PatientTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.l10n,
    required this.requiredValidator,
    this.isNumber = false,
    this.maxLines = 1,
    this.required = true,
    this.onChanged,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onEditingComplete,
    this.focusNode,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final AppLocalizations l10n;
  final String? Function(String?, AppLocalizations) requiredValidator;
  final bool isNumber;
  final int maxLines;
  final bool required;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? Function(String?, AppLocalizations)? validator;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textInputAction: textInputAction,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      validator: (value) => (validator != null)
          ? validator!(value, l10n)
          : (!required)
          ? null
          : requiredValidator(value, l10n),
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class PatientDateField extends StatelessWidget {
  const PatientDateField({
    super.key,
    required this.label,
    required this.controller,
    required this.l10n,
    required this.requiredValidator,
    required this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final AppLocalizations l10n;
  final String? Function(String?, AppLocalizations) requiredValidator;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      validator: (value) => requiredValidator(value, l10n),
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class PatientPhoneField extends StatelessWidget {
  const PatientPhoneField({
    super.key,
    required this.label,
    required this.controller,
    required this.l10n,
    required this.scheme,
    required this.countryCode,
    required this.phoneValidator,
    required this.phoneFieldValue,
  });

  final String label;
  final TextEditingController controller;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final String countryCode;
  final String? Function(PhoneNumber?, AppLocalizations) phoneValidator;
  final String Function(String) phoneFieldValue;

  @override
  Widget build(BuildContext context) => Padding(
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
      initialValue: phoneFieldValue(controller.text),
      dropdownIcon: Icon(Icons.arrow_drop_down, color: scheme.primary.withValues(alpha: 0.7)),
      style: TextStyle(color: scheme.onSurfaceVariant),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (phone) => phoneValidator(phone, l10n),
      onChanged: (phone) => controller.text = phone.completeNumber,
      textInputAction: TextInputAction.next,
    ),
  );
}

class PatientDropdownIntField extends StatelessWidget {
  const PatientDropdownIntField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.fillColor,
    this.floatingLabelBehavior,
    this.hintText,
  });

  final String label;
  final int? value;
  final Map<int, String> options;
  final ValueChanged<int> onChanged;
  final Color? fillColor;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final String? hintText;

  @override
  Widget build(BuildContext context) => Padding(
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
}

class PatientCountryField extends StatelessWidget {
  const PatientCountryField({
    super.key,
    required this.label,
    required this.controller,
    required this.onSelectCountry,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<Country> onSelectCountry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: () => showCountryPicker(context: context, showPhoneCode: false, onSelect: onSelectCountry),
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
}

class PatientCheckboxField extends StatelessWidget {
  const PatientCheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.trueLabel,
    required this.falseLabel,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String trueLabel;
  final String falseLabel;

  @override
  Widget build(BuildContext context) => Padding(
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
