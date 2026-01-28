import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(
          height: isWide ? 150 : 130,
          child: Image.asset('assets/images/logo_sl_v.png', fit: BoxFit.contain),
        ),
        Text(
          l10n.appTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 6),
        Text(
          l10n.brandTagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isWide ? 18 : 16,
            fontWeight: FontWeight.w500,
            color: scheme.primary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
