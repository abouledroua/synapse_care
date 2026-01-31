import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';
import '../../controller/theme_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';
import '../widget/auth_doctor_section.dart';
import '../widget/auth_sms_section.dart';
import '../widget/brand_header.dart';
import '../widget/role_selector.dart';
import '../widget/synapse_background.dart';

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({super.key});

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final AuthController _controller = AuthController();

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
          // Block system back on login.
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
                            RoleSelector(isDoctor: _controller.isDoctor, onChanged: _controller.setDoctor),
                            const SizedBox(height: 24),
                            if (!_controller.isDoctor) ...[
                              AuthSmsSection(
                                controller: _controller,
                                l10n: l10n,
                                scheme: scheme,
                                onContinue: () async {
                                  ThemeController.instance.setIndex(3);

                                  if (!_controller.canContinue) return;

                                  _controller.setBusy(true);
                                  try {
                                    final messenger = ScaffoldMessenger.of(context);
                                    final first = messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.otpSend(_controller.phoneNumber)),
                                        duration: const Duration(milliseconds: 1300),
                                      ),
                                    );

                                    await first.closed;
                                    await Future.delayed(const Duration(seconds: 1));

                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.otpValidDemo(_controller.phoneNumber)),
                                        duration: const Duration(milliseconds: 1300),
                                      ),
                                    );
                                  } finally {
                                    _controller.setBusy(false);
                                  }
                                },
                              ),
                            ] else ...[
                              AuthDoctorSection(
                                controller: _controller,
                                isLogin: true,
                                l10n: l10n,
                                scheme: scheme,
                                onSubmit: () async {
                                  final isValid = _controller.validateDoctorLogin(
                                    emailEmptyMessage: l10n.emailEmptyError,
                                    emailInvalidMessage: l10n.emailInvalidError,
                                    passwordEmptyMessage: l10n.passwordEmptyError,
                                  );
                                  if (!isValid) return;

                                  _controller.setBusy(true);
                                  try {
                                    final error = await _controller.loginDoctor(
                                      email: _controller.emailController.text.trim(),
                                      password: _controller.passwordController.text,
                                      invalidMessage: l10n.loginInvalid,
                                      genericMessage: l10n.loginFailed,
                                      networkMessage: l10n.loginNetworkError,
                                    );
                                    if (!mounted) return;

                                    final messenger = ScaffoldMessenger.of(context);
                                    if (error != null) {
                                      return;
                                    }
                                    messenger.showSnackBar(
                                      SnackBar(content: Text(l10n.loginSuccess)),
                                    );
                                    context.push('/cabinet/select');
                                  } finally {
                                    _controller.setBusy(false);
                                  }
                                },
                                onFooterTap: () => context.go('/auth/signup'),
                              ),
                            ],
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
