import 'package:flutter/material.dart';
import 'toggle_button.dart';
import '../../l10n/app_localizations.dart';

class AuthToggle extends StatelessWidget {
  const AuthToggle({super.key, required this.isLogin, required this.onChanged});

  final bool isLogin;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: ToggleButton(label: l10n.login, selected: isLogin, onTap: () => onChanged(true)),
          ),
          Expanded(
            child: ToggleButton(label: l10n.signup, selected: !isLogin, onTap: () => onChanged(false)),
          ),
        ],
      ),
    );
  }
}
