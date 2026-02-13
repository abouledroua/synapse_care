import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../l10n/app_localizations.dart';
import '../../core/config/api_config.dart';
import '../widget/input_card.dart';
import '../widget/primary_button.dart';
import '../widget/app_background.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  int _step = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.emailEmptyError)));
      return;
    }
    setState(() => _sending = true);
    try {
      final uri = Uri.parse('${ApiConfig.resolveBaseUrl()}/auth/forgot');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: '{"email":${jsonEncode(email)}}',
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => _step = 1);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordCodeSent)));
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordEmailNotFound)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.loginNetworkError)));
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_sending) return;
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordInvalidCode)));
      return;
    }
    setState(() => _sending = true);
    try {
      final uri = Uri.parse('${ApiConfig.resolveBaseUrl()}/auth/verify-reset');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: '{"email":${jsonEncode(email)},"code":${jsonEncode(code)}}',
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => _step = 2);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordInvalidCode)));
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_sending) return;
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordTooShort)));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordMismatch)));
      return;
    }
    setState(() => _sending = true);
    try {
      final uri = Uri.parse('${ApiConfig.resolveBaseUrl()}/auth/reset-password');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body:
            '{"email":${jsonEncode(email)},"code":${jsonEncode(code)},"new_password":${jsonEncode(password)}}',
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordResetSuccess)));
        context.go('/auth/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordInvalidCode)));
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: Center(
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back),
                            color: scheme.primary,
                          ),
                        ),
                        Text(
                          l10n.forgotPasswordTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.forgotPasswordSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(height: 20),
                      if (_step == 0) ...[
                        InputCard(
                          icon: Icons.email_outlined,
                          hintText: l10n.forgotPasswordEmailHint,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: _sending ? l10n.forgotPasswordSending : l10n.forgotPasswordSend,
                          onPressed: _sending ? null : () => _submit(),
                        ),
                      ],
                      if (_step == 1) ...[
                        InputCard(
                          icon: Icons.password,
                          hintText: l10n.forgotPasswordCodeHint,
                          keyboardType: TextInputType.number,
                          controller: _codeController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _verifyCode(),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: _sending ? l10n.forgotPasswordSending : l10n.forgotPasswordVerify,
                          onPressed: _sending ? null : () => _verifyCode(),
                        ),
                      ],
                      if (_step == 2) ...[
                        InputCard(
                          icon: Icons.lock_outline,
                          hintText: l10n.forgotPasswordNewPasswordHint,
                          obscureText: true,
                          controller: _passwordController,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        InputCard(
                          icon: Icons.lock_outline,
                          hintText: l10n.forgotPasswordConfirmPasswordHint,
                          obscureText: true,
                          controller: _confirmController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _resetPassword(),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: _sending ? l10n.forgotPasswordSending : l10n.forgotPasswordReset,
                          onPressed: _sending ? null : () => _resetPassword(),
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
    );
  }
}
