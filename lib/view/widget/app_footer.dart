import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static final Uri _contactEmailUri = Uri(
    scheme: 'mailto',
    path: 'amor.bouledroua@gmail.com',
    queryParameters: {'subject': 'Curatio support'},
  );
  static final Uri _contactPhoneUri = Uri(scheme: 'tel', path: '+213778750333');
  static final Uri _contactWhatsAppWebUri = Uri.parse('https://wa.me/213778750333');

  Future<void> _openEmailClient() async {
    await launchUrl(_contactEmailUri);
  }

  Future<void> _openPhoneDialer() async {
    if (kIsWeb) {
      await launchUrl(_contactWhatsAppWebUri, mode: LaunchMode.externalApplication);
      return;
    }
    await launchUrl(_contactPhoneUri);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isWide = (MediaQuery.of(context).size.width >= LayoutConstants.wideBreakpoint);
    final emailParts = l10n.footerContactEmail.split(':');
    final emailLabel = emailParts.length > 1 ? '${emailParts.first.trim()} :' : 'Email :';
    final emailValue = emailParts.length > 1 ? emailParts.sublist(1).join(':').trim() : l10n.footerContactEmail;
    final phoneParts = l10n.footerContactPhone.split(':');
    final phoneLabel = phoneParts.length > 1 ? '${phoneParts.first.trim()} :' : 'Phone :';
    final phoneValue = phoneParts.length > 1 ? phoneParts.sublist(1).join(':').trim() : l10n.footerContactPhone;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = Text(
            l10n.footerContactTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.92),
            ),
          );
          final contactBlock = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.envelope, size: 12, color: scheme.onSurfaceVariant.withValues(alpha: 0.92)),
                  const SizedBox(width: 4),
                  Text(
                    emailLabel,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.15,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.92),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: InkWell(
                      onTap: _openEmailClient,
                      child: Text(
                        emailValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.15,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.phone, size: 12, color: scheme.onSurfaceVariant.withValues(alpha: 0.92)),
                  const SizedBox(width: 4),
                  Text(
                    phoneLabel,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.15,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.92),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: InkWell(
                      onTap: _openPhoneDialer,
                      child: Text(
                        phoneValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.15,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          return Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 6))],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Image.asset('assets/images/logo.png', width: 25, height: 25),
                  const SizedBox(width: 6),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color.fromARGB(255, 7, 78, 141), Color.fromARGB(255, 41, 184, 187)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(l10n.appTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isWide) title,
                        if (isWide) const SizedBox(width: 20),
                        Flexible(child: contactBlock),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
