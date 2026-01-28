import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/locale_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/primary_button.dart';
import '../widget/synapse_background.dart';

class LanguagePickerPage extends StatelessWidget {
  const LanguagePickerPage({super.key});

  Future<void> _select(BuildContext context, Locale locale) async {
    await LocaleController.instance.setLocale(locale);
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          const SynapseBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.chooseLanguage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'العربية',
                        onPressed: () => _select(context, const Locale('ar')),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Français',
                        onPressed: () => _select(context, const Locale('fr')),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'English',
                        onPressed: () => _select(context, const Locale('en')),
                      ),
                    ],
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
