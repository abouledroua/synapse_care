import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';
import '../widget/auth_doctor_section.dart';
import '../widget/brand_header.dart';
import '../widget/app_background.dart';

class AuthSignupPage extends StatefulWidget {
  const AuthSignupPage({super.key});

  @override
  State<AuthSignupPage> createState() => _AuthSignupPageState();
}

class _AuthSignupPageState extends State<AuthSignupPage> {
  final AuthController _controller = AuthController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.setRole(AuthRole.doctor);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            context.go('/auth/login');
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              const AppBackground(),
              SafeArea(
                child: Center(
                  child: AbsorbPointer(
                    absorbing: _controller.isBusy,
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: kIsWeb ? true : null,
                      thickness: kIsWeb ? 6 : null,
                      radius: kIsWeb ? const Radius.circular(8) : null,
                      trackVisibility: kIsWeb ? true : null,
                      interactive: kIsWeb ? true : null,
                      child: SingleChildScrollView(
                        controller: _scrollController,
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
                                    if (!context.mounted) return;

                                    final messenger = ScaffoldMessenger.of(context);
                                    if (error != null) {
                                      messenger.showSnackBar(
                                        SnackBar(content: Text(_localizedSignupError(error, l10n))),
                                      );
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedSignupError(String error, AppLocalizations l10n) {
    final normalized = error.toLowerCase();
    if (normalized.contains('email') && normalized.contains('exists')) {
      return l10n.signupEmailExists;
    }
    if (normalized.contains('phone') && normalized.contains('exists')) {
      return l10n.signupPhoneExists;
    }
    if (normalized.contains('network')) {
      return l10n.loginNetworkError;
    }
    return l10n.signupFailed;
  }
}
