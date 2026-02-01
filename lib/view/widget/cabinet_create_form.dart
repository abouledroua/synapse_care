import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../l10n/app_localizations.dart';
import 'input_card.dart';
import 'primary_button.dart';

class CabinetCreatePayload {
  const CabinetCreatePayload({
    required this.name,
    required this.specialty,
    required this.address,
    required this.phone,
    this.photoBytes,
    this.photoExtension,
  });

  final String name;
  final String specialty;
  final String address;
  final String phone;
  final Uint8List? photoBytes;
  final String? photoExtension;
}

class CabinetCreateForm extends StatefulWidget {
  const CabinetCreateForm({
    super.key,
    required this.l10n,
    required this.scheme,
    required this.onSubmit,
    this.nameErrorText,
    this.onNameChanged,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ValueChanged<CabinetCreatePayload> onSubmit;
  final String? nameErrorText;
  final ValueChanged<String>? onNameChanged;

  @override
  State<CabinetCreateForm> createState() => _CabinetCreateFormState();
}

class _CabinetCreateFormState extends State<CabinetCreateForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _specialtyFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;
  Uint8List? _photoBytes;
  String? _photoExtension;

  String? _nameError;
  String? _phoneError;
  String _phoneNumber = '';

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _specialtyFocus.dispose();
    _addressFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = _extensionFromPath(picked.path);
    setState(() {
      _photo = picked;
      _photoBytes = bytes;
      _photoExtension = ext;
    });
  }

  void _clearPhoto() {
    setState(() {
      _photo = null;
      _photoBytes = null;
      _photoExtension = null;
    });
  }

  String _extensionFromPath(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return 'jpg';
    return path.substring(dot + 1).toLowerCase();
  }

  bool _validateName() {
    final value = _nameController.text.trim();
    if (value.isEmpty) {
      _nameError = widget.l10n.cabinetNameEmptyError;
    } else {
      _nameError = null;
    }
    setState(() {});
    return _nameError == null;
  }

  String? _validatePhone(PhoneNumber? phone) {
    _phoneNumber = '';
    if (phone == null || phone.number.isEmpty) {
      _phoneError = widget.l10n.phoneEmptyError;
      setState(() {});
      return _phoneError;
    }
    if (phone.countryCode == '+213') {
      if (!RegExp(r'^[567]').hasMatch(phone.number) || phone.number.length < 9) {
        _phoneError = widget.l10n.phoneInvalidPrefixError;
        setState(() {});
        return _phoneError;
      }
    }
    _phoneNumber = phone.completeNumber;
    _phoneError = null;
    setState(() {});
    return null;
  }

  void _handlePhoneChanged(PhoneNumber phone) {
    _phoneNumber = '';
    if (phone.countryCode == '+213' && phone.number.isNotEmpty) {
      if (!RegExp(r'^[567]').hasMatch(phone.number) || phone.number.length < 9) {
        _phoneError = widget.l10n.phoneInvalidPrefixError;
      } else {
        _phoneNumber = phone.completeNumber;
        _phoneError = null;
      }
      setState(() {});
      return;
    }
    _phoneNumber = phone.completeNumber;
    _phoneError = null;
    setState(() {});
  }

  bool _validatePhoneOnSubmit() {
    if (_phoneNumber.isEmpty) {
      _phoneError = widget.l10n.phoneEmptyError;
      setState(() {});
      return false;
    }
    return _phoneError == null;
  }

  void _submit() {
    final nameOk = _validateName();
    final phoneOk = _validatePhoneOnSubmit();
    if (!nameOk || !phoneOk) return;

    widget.onSubmit(
      CabinetCreatePayload(
        name: _nameController.text.trim(),
        specialty: _specialtyController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneNumber,
        photoBytes: _photoBytes,
        photoExtension: _photoExtension,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: widget.scheme.primary.withValues(alpha: 0.15),
              backgroundImage: _photo != null ? FileImage(File(_photo!.path)) : null,
              child: _photo == null
                  ? Icon(Icons.photo_camera_outlined, size: 30, color: widget.scheme.primary.withValues(alpha: 0.8))
                  : null,
            ),
          ),
          if (_photo != null)
            GestureDetector(
              onTap: _clearPhoto,
              child: Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: widget.scheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Icon(Icons.close, size: 14, color: widget.scheme.primary),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      InputCard(
        icon: Icons.local_hospital_outlined,
        hintText: widget.l10n.cabinetNameHint,
        keyboardType: TextInputType.name,
        controller: _nameController,
        focusNode: _nameFocus,
        onSubmitted: (_) => _specialtyFocus.requestFocus(),
        onChanged: (value) {
          _validateName();
          widget.onNameChanged?.call(value);
        },
        errorText: _nameError ?? widget.nameErrorText,
      ),
      const SizedBox(height: 16),
      InputCard(
        icon: Icons.medical_information_outlined,
        hintText: widget.l10n.specialtyHint,
        keyboardType: TextInputType.multiline,
        controller: _specialtyController,
        focusNode: _specialtyFocus,
        textInputAction: TextInputAction.newline,
        maxLines: 3,
        minLines: 1,
        onSubmitted: (_) => _addressFocus.requestFocus(),
      ),
      const SizedBox(height: 16),
      InputCard(
        icon: Icons.location_on_outlined,
        hintText: widget.l10n.cabinetAddressHint,
        keyboardType: TextInputType.multiline,
        controller: _addressController,
        focusNode: _addressFocus,
        textInputAction: TextInputAction.newline,
        maxLines: 3,
        minLines: 1,
        onSubmitted: (_) => _phoneFocus.requestFocus(),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 58,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
          ),
          child: IntlPhoneField(
            focusNode: _phoneFocus,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.l10n.phoneHint,
              hintStyle: TextStyle(color: widget.scheme.primary.withValues(alpha: 0.5)),
              errorText: _phoneError,
            ),
            initialCountryCode: 'DZ',
            dropdownIcon: Icon(Icons.arrow_drop_down, color: widget.scheme.primary.withValues(alpha: 0.7)),
            style: TextStyle(color: widget.scheme.onSurfaceVariant),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validatePhone,
            onChanged: _handlePhoneChanged,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ),
      ),
      const SizedBox(height: 12),
      PrimaryButton(label: widget.l10n.cabinetCreateSubmit, onPressed: _submit),
    ],
  );
}
