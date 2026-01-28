import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class FooterLink extends StatelessWidget {
  const FooterLink({super.key, required this.isLogin, required this.onTap});

  final bool isLogin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(
          isLogin ? l10n.newHere : l10n.haveAccount,
          style: TextStyle(color: scheme.primary.withValues(alpha: 0.7)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            isLogin ? l10n.createAccount : l10n.signIn,
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
