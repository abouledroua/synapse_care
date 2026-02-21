import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import 'auth_login_form.dart';
import 'auth_signup_form.dart';
import 'footer_link.dart';

class AuthDoctorSection extends StatelessWidget {
  const AuthDoctorSection({
    super.key,
    required this.controller,
    required this.isLogin,
    required this.l10n,
    required this.scheme,
    required this.onSubmit,
    required this.onFooterTap,
  });

  final AuthController controller;
  final bool isLogin;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final VoidCallback onSubmit;
  final VoidCallback onFooterTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      isLogin
          ? AuthLoginForm(controller: controller, l10n: l10n, scheme: scheme, onSubmit: onSubmit)
          : AuthSignupForm(controller: controller, l10n: l10n, scheme: scheme, onSubmit: onSubmit),
      // const SizedBox(height: 18),
      FooterLink(isLogin: isLogin, onTap: onFooterTap),
    ],
  );
}
