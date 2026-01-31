import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';
import '../widget/auth_doctor_section.dart';
import '../widget/brand_header.dart';
import '../widget/synapse_background.dart';

class AuthSignupPage extends StatefulWidget {
  const AuthSignupPage({super.key});

  @override
  State<AuthSignupPage> createState() => _AuthSignupPageState();
}

class _AuthSignupPageState extends State<AuthSignupPage> {
  final AuthController _controller = AuthController();

  @override
  void initState() {
    super.initState();
    _controller.setDoctor(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= LayoutConstants.wideBreakpoint;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            context.go('/auth/login');
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              const SynapseBackground(),
              SafeArea(
                child: Center(
                  child: AbsorbPointer(
                    absorbing: _controller.isBusy,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BrandHeader(isWide: isWide),
                            const SizedBox(height: 22),
                            AuthDoctorSection(
                              controller: _controller,
                              isLogin: false,
                              l10n: l10n,
                              scheme: scheme,
                              onSubmit: () async {
                                final isValid = _controller.validateDoctorSignup(
                                  nameEmptyMessage: l10n.nameEmptyError,
                                  emailEmptyMessage: l10n.emailEmptyError,
                                  emailInvalidMessage: l10n.emailInvalidError,
                                  specialtyEmptyMessage: l10n.specialtyEmptyError,
                                  phoneEmptyMessage: l10n.phoneEmptyError,
                                  passwordTooShort: l10n.passwordTooShort,
                                  passwordNeedSpecial: l10n.passwordNeedSpecial,
                                  passwordNeedUpper: l10n.passwordNeedUpper,
                                  passwordMismatch: l10n.passwordMismatch,
                                );
                                if (!isValid) return;

                                _controller.setBusy(true);
                                try {
                                  final error = await _controller.registerDoctor(
                                    fullname: _controller.nameController.text.trim(),
                                    email: _controller.emailController.text.trim(),
                                    phone: _controller.phoneNumber,
                                    password: _controller.passwordController.text,
                                    speciality: _controller.specialtyController.text.trim(),
                                  );
                                  if (!mounted) return;

                                  final messenger = ScaffoldMessenger.of(context);
                                  if (error != null) {
                                    messenger.showSnackBar(SnackBar(content: Text(error)));
                                    debugPrint('Signup error: $error');
                                    return;
                                  }
                                  messenger.showSnackBar(SnackBar(content: Text(l10n.signup)));
                                  context.go('/auth/login');
                                } finally {
                                  _controller.setBusy(false);
                                }
                              },
                              onFooterTap: () => context.go('/auth/login'),
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
      ),
    );
  }
}
