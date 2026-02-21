import 'package:flutter/foundation.dart';
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
import '../widget/app_background.dart';
import '../widget/app_footer.dart';

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({super.key});

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final AuthController _controller = AuthController();
  final ScrollController _scrollController = ScrollController();

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
        onPopInvokedWithResult: (didPop, result) {},
        child: Scaffold(
          bottomNavigationBar: const AppFooter(),
          body: Stack(
            children: [
              const AppBackground(showFooter: false),
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
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              BrandHeader(isWide: isWide),
                              const SizedBox(height: 10),
                              if (_controller.isBusy)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: CircularProgressIndicator(),
                                )
                              else ...[
                                RoleSelector(role: _controller.role, onChanged: _controller.setRole),
                                const SizedBox(height: 16),
                                if (_controller.isPatient) ...[
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
                                        if (!context.mounted) return;
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
                                      final result = await _controller.submitDoctorLogin(
                                        emailEmptyMessage: l10n.emailEmptyError,
                                        emailInvalidMessage: l10n.emailInvalidError,
                                        passwordEmptyMessage: l10n.passwordEmptyError,
                                        invalidMessage: l10n.loginInvalid,
                                        genericMessage: l10n.loginFailed,
                                        networkMessage: l10n.loginNetworkError,
                                      );
                                      if (!context.mounted || !result.success) return;
                                      final messenger = ScaffoldMessenger.of(context);
                                      messenger.showSnackBar(SnackBar(content: Text(l10n.loginSuccess)));
                                      if (result.target == AuthLoginTarget.platformAdmin) {
                                        context.go('/admin/clinics');
                                      } else {
                                        context.go('/cabinet/select');
                                      }
                                    },
                                    onFooterTap: () => context.go('/auth/signup'),
                                  ),
                                ],
                              ],
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
}
