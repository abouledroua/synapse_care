import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import 'input_card.dart';
import 'primary_button.dart';

class AuthLoginForm extends StatelessWidget {
  const AuthLoginForm({
    super.key,
    required this.controller,
    required this.l10n,
    required this.scheme,
    required this.onSubmit,
  });

  final AuthController controller;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => AutofillGroup(
    child: Column(
      children: [
        InputCard(
          icon: Icons.email_outlined,
          hintText: l10n.emailHint,
          keyboardType: TextInputType.emailAddress,
          controller: controller.emailController,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          onChanged: (value) => controller.validateLoginEmail(
            value,
            emptyMessage: l10n.emailEmptyError,
            invalidMessage: l10n.emailInvalidError,
          ),
          errorText: controller.loginEmailError,
        ),
        const SizedBox(height: 16),
        InputCard(
          icon: Icons.lock_outline,
          hintText: l10n.passwordHint,
          obscureText: controller.obscurePassword,
          controller: controller.passwordController,
          autofillHints: const [AutofillHints.password],
          onChanged: (value) => controller.validateLoginPassword(value, emptyMessage: l10n.passwordEmptyError),
          errorText: controller.loginPasswordError,
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: scheme.primary.withValues(alpha: 0.7),
            ),
            onPressed: controller.toggleObscurePassword,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push('/auth/forgot'),
            child: Text(l10n.forgotPassword, style: TextStyle(color: scheme.primary.withValues(alpha: 0.7))),
          ),
        ),
        if (controller.loginSubmitError != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(controller.loginSubmitError!, style: TextStyle(color: scheme.error, fontSize: 13)),
          ),
        ],
        const SizedBox(height: 2),
        PrimaryButton(label: l10n.login, onPressed: onSubmit),
      ],
    ),
  );
}
