import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../controller/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import 'primary_button.dart';

class AuthSmsSection extends StatelessWidget {
  const AuthSmsSection({
    super.key,
    required this.controller,
    required this.l10n,
    required this.scheme,
    required this.onContinue,
  });

  final AuthController controller;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 58,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10)),
            ],
          ),
          child: IntlPhoneField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: l10n.phoneHint,
              hintStyle: TextStyle(color: scheme.primary.withValues(alpha: 0.5)),
              errorText: controller.phoneError,
            ),
            initialCountryCode: 'DZ',
            dropdownIcon: Icon(Icons.arrow_drop_down, color: scheme.primary.withValues(alpha: 0.7)),
            style: TextStyle(color: scheme.onSurfaceVariant),
            validator: (phone) => controller.validatePhone(
              phone,
              emptyMessage: l10n.phoneEmptyError,
              invalidPrefixMessage: l10n.phoneInvalidPrefixError,
            ),
            onChanged: (phone) => controller.handlePhoneChanged(
              phone,
              invalidPrefixMessage: l10n.phoneInvalidPrefixError,
            ),
          ),
        ),
      ),
      const SizedBox(height: 2),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            l10n.quickSms,
            textAlign: TextAlign.right,
            style: TextStyle(color: scheme.primary.withValues(alpha: 0.7)),
          ),
        ],
      ),
      const SizedBox(height: 8),
      PrimaryButton(
        label: l10n.continueCta,
        onPressed: onContinue,
      ),
    ],
  );
}
