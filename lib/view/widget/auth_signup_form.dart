import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../controller/auth_controller.dart';
import '../../controller/photo_picker_controller.dart';
import '../../l10n/app_localizations.dart';
import 'input_card.dart';
import 'primary_button.dart';

class AuthSignupForm extends StatefulWidget {
  const AuthSignupForm({
    super.key,
    required this.controller,
    required this.l10n,
    required this.scheme,
    required this.onSubmit,
    this.submitLabel,
    this.nameHint,
    this.addressController,
    this.addressHint,
    this.addressError,
    this.addressMaxLines,
    this.addressMinLines,
    this.onAddressChanged,
    this.showEmail = true,
    this.showPassword = true,
    this.showConfirmPassword = true,
  });

  final AuthController controller;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final VoidCallback onSubmit;
  final String? submitLabel;
  final String? nameHint;
  final TextEditingController? addressController;
  final String? addressHint;
  final String? addressError;
  final int? addressMaxLines;
  final int? addressMinLines;
  final ValueChanged<String>? onAddressChanged;
  final bool showEmail;
  final bool showPassword;
  final bool showConfirmPassword;

  @override
  State<AuthSignupForm> createState() => _AuthSignupFormState();
}

class _AuthSignupFormState extends State<AuthSignupForm> {
  final _nameFocus = FocusNode();
  final _specialtyFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final PhotoPickerController _photoController = PhotoPickerController();

  @override
  void dispose() {
    _nameFocus.dispose();
    _specialtyFocus.dispose();
    _addressFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _phoneFocus.dispose();
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitLabel = widget.submitLabel ?? widget.l10n.signup;
    final nameHint = widget.nameHint ?? widget.l10n.nameHint;
    final showAddress = widget.addressController != null;
    final addressHint = widget.addressHint ?? widget.l10n.cabinetAddressHint;
    return Column(
      children: [
        if (widget.controller.isDoctor) ...[
          AnimatedBuilder(
            animation: _photoController,
            builder: (context, child) {
              final photo = _photoController.photo;
              return Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () => _photoController.pickFromGallery(widget.controller),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: widget.scheme.primary.withValues(alpha: 0.15),
                      backgroundImage: photo != null ? FileImage(File(photo.path)) : null,
                      child: photo == null
                          ? Icon(
                              Icons.photo_camera_outlined,
                              size: 30,
                              color: widget.scheme.primary.withValues(alpha: 0.8),
                            )
                          : null,
                    ),
                  ),
                  if (photo != null)
                    GestureDetector(
                      onTap: () => _photoController.clear(widget.controller),
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
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      InputCard(
        icon: Icons.person_outline,
        hintText: nameHint,
        keyboardType: TextInputType.name,
        controller: widget.controller.nameController,
        focusNode: _nameFocus,
        onSubmitted: (_) => widget.controller.isDoctor ? _specialtyFocus.requestFocus() : _emailFocus.requestFocus(),
        onChanged: (value) => widget.controller.validateName(
          value,
          emptyMessage: widget.l10n.nameEmptyError,
        ),
        errorText: widget.controller.nameError,
      ),
      if (widget.controller.isDoctor) ...[
        const SizedBox(height: 16),
        InputCard(
          icon: Icons.medical_information_outlined,
          hintText: widget.l10n.specialtyHint,
          keyboardType: TextInputType.multiline,
          controller: widget.controller.specialtyController,
          focusNode: _specialtyFocus,
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 1,
          onSubmitted: (_) => showAddress ? _addressFocus.requestFocus() : _emailFocus.requestFocus(),
          onChanged: (value) => widget.controller.validateSpecialty(
            value,
            emptyMessage: widget.l10n.specialtyEmptyError,
          ),
          errorText: widget.controller.specialtyError,
        ),
        if (showAddress) ...[
          const SizedBox(height: 16),
          InputCard(
            icon: Icons.location_on_outlined,
            hintText: addressHint,
            keyboardType: TextInputType.multiline,
            controller: widget.addressController,
            focusNode: _addressFocus,
            textInputAction: TextInputAction.newline,
            maxLines: widget.addressMaxLines ?? 3,
            minLines: widget.addressMinLines ?? 1,
            onSubmitted: (_) => _emailFocus.requestFocus(),
            onChanged: widget.onAddressChanged,
            errorText: widget.addressError,
          ),
        ],
      ],
      if (widget.showEmail) ...[
        const SizedBox(height: 16),
        InputCard(
          icon: Icons.email_outlined,
          hintText: widget.l10n.emailHint,
          keyboardType: TextInputType.emailAddress,
          controller: widget.controller.emailController,
          focusNode: _emailFocus,
          onSubmitted: (_) => widget.showPassword ? _passwordFocus.requestFocus() : _phoneFocus.requestFocus(),
          onChanged: (value) => widget.controller.validateEmail(
            value,
            emptyMessage: widget.l10n.emailEmptyError,
            invalidMessage: widget.l10n.emailInvalidError,
          ),
          errorText: widget.controller.emailError,
        ),
      ],
      if (widget.showPassword) ...[
        const SizedBox(height: 16),
        InputCard(
          icon: Icons.lock_outline,
          hintText: widget.l10n.passwordHint,
          obscureText: widget.controller.obscurePassword,
          controller: widget.controller.passwordController,
          focusNode: _passwordFocus,
          onSubmitted: (_) => widget.showConfirmPassword ? _confirmFocus.requestFocus() : _phoneFocus.requestFocus(),
          onChanged: (value) => widget.controller.updatePassword(
            value,
            tooShort: widget.l10n.passwordTooShort,
            needSpecial: widget.l10n.passwordNeedSpecial,
            needUpper: widget.l10n.passwordNeedUpper,
            mismatch: widget.l10n.passwordMismatch,
          ),
          errorText: widget.controller.passwordError,
          suffixIcon: IconButton(
            icon: Icon(
              widget.controller.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: widget.scheme.primary.withValues(alpha: 0.7),
            ),
            onPressed: widget.controller.toggleObscurePassword,
          ),
        ),
      ],
      if (widget.showConfirmPassword) ...[
        const SizedBox(height: 16),
        InputCard(
          icon: Icons.lock_outline,
          hintText: widget.l10n.confirmPasswordHint,
          obscureText: widget.controller.obscurePassword,
          controller: widget.controller.confirmController,
          focusNode: _confirmFocus,
          onSubmitted: (_) => _phoneFocus.requestFocus(),
          onChanged: (value) => widget.controller.updateConfirmPassword(
            value,
            tooShort: widget.l10n.passwordTooShort,
            needSpecial: widget.l10n.passwordNeedSpecial,
            needUpper: widget.l10n.passwordNeedUpper,
            mismatch: widget.l10n.passwordMismatch,
          ),
          errorText: widget.controller.confirmPasswordError,
          suffixIcon: IconButton(
            icon: Icon(
              widget.controller.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: widget.scheme.primary.withValues(alpha: 0.7),
            ),
            onPressed: widget.controller.toggleObscurePassword,
          ),
        ),
      ],
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
              errorText: widget.controller.phoneError,
            ),
            initialCountryCode: 'DZ',
            dropdownIcon: Icon(Icons.arrow_drop_down, color: widget.scheme.primary.withValues(alpha: 0.7)),
            style: TextStyle(color: widget.scheme.onSurfaceVariant),
            validator: (phone) => widget.controller.validatePhone(
              phone,
              emptyMessage: widget.l10n.phoneEmptyError,
              invalidPrefixMessage: widget.l10n.phoneInvalidPrefixError,
            ),
            onChanged: (phone) => widget.controller.handlePhoneChanged(
              phone,
              invalidPrefixMessage: widget.l10n.phoneInvalidPrefixError,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => widget.onSubmit(),
          ),
        ),
      ),
      const SizedBox(height: 12),
      PrimaryButton(label: submitLabel, onPressed: widget.onSubmit),
    ],
    );
  }
}
