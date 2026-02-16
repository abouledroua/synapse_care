import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';
import '../../controller/locale_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.dateText,
    required this.timeText,
    required this.scheme,
    required this.l10n,
    required this.isWide,
    required this.doctorName,
    required this.clinicName,
    required this.userPhotoUrl,
    required this.isPlatformAdmin,
    this.searchBar,
    this.onChangeClinic,
  });

  final String dateText;
  final String timeText;
  final ColorScheme scheme;
  final AppLocalizations l10n;
  final bool isWide;
  final String? doctorName;
  final String? clinicName;
  final String? userPhotoUrl;
  final bool isPlatformAdmin;
  final Widget? searchBar;
  final Future<void> Function()? onChangeClinic;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < LayoutConstants.wideBreakpoint;
        return Row(
          children: [
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.calendarDays, size: 16, color: scheme.primary.withValues(alpha: 0.8)),
                    const SizedBox(width: 6),
                    Text(
                      dateText,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.clock, size: 14, color: scheme.primary.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Text(
                      timeText,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (searchBar != null) ...[const SizedBox(width: 10), Expanded(child: searchBar!)] else ...[const Spacer()],
            const SizedBox(width: 12),
            PopupMenuButton<_LanguageChoice>(
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              color: Colors.white.withValues(alpha: 0.96),
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tooltip: l10n.chooseLanguage,
              onSelected: (value) {
                final locale = switch (value) {
                  _LanguageChoice.en => const Locale('en'),
                  _LanguageChoice.fr => const Locale('fr'),
                  _LanguageChoice.ar => const Locale('ar'),
                };
                LocaleController.instance.setLocale(locale);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _LanguageChoice.en,
                  child: _LanguageMenuItem(
                    flag: const _FlagIcon(type: _FlagType.england, size: 20),
                    label: l10n.languageEnglish,
                    isSelected: l10n.localeName.startsWith('en'),
                  ),
                ),
                PopupMenuItem(
                  value: _LanguageChoice.fr,
                  child: _LanguageMenuItem(
                    flag: const _FlagIcon(type: _FlagType.france, size: 20),
                    label: l10n.languageFrench,
                    isSelected: l10n.localeName.startsWith('fr'),
                  ),
                ),
                PopupMenuItem(
                  value: _LanguageChoice.ar,
                  child: _LanguageMenuItem(
                    flag: const _FlagIcon(type: _FlagType.algeria, size: 20),
                    label: l10n.languageArabic,
                    isSelected: l10n.localeName.startsWith('ar'),
                  ),
                ),
              ],
              child: _FlagIcon(type: _flagForLocale(l10n.localeName), size: isWide ? 26 : 22),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<_ProfileAction>(
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              color: Colors.white.withValues(alpha: 0.96),
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) async {
                switch (value) {
                  case _ProfileAction.profile:
                    context.push('/profile');
                    break;
                  case _ProfileAction.changeClinic:
                    if (onChangeClinic != null) {
                      await onChangeClinic!();
                    } else {
                      if (!context.mounted) return;
                      context.push('/cabinet/select');
                    }
                    break;
                  case _ProfileAction.adminPanel:
                    context.push('/admin/clinics');
                    break;
                  case _ProfileAction.logout:
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l10n.homeMenuLogout),
                        content: Text(l10n.homeLogoutConfirmMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: Text(l10n.homeMenuLogout),
                          ),
                        ],
                      ),
                    );
                    if (!context.mounted) return;
                    if (shouldLogout != true) return;
                    final controller = AuthController();
                    controller.logout();
                    context.go('/auth/login');
                    break;
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _ProfileAction.profile,
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: scheme.primary),
                      const SizedBox(width: 10),
                      Text(l10n.homeMenuProfile, style: _menuTextStyle(scheme)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _ProfileAction.changeClinic,
                  child: Row(
                    children: [
                      Icon(Icons.local_hospital_outlined, color: scheme.primary),
                      const SizedBox(width: 10),
                      Text(l10n.homeMenuChangeClinic, style: _menuTextStyle(scheme)),
                    ],
                  ),
                ),
                if (isPlatformAdmin)
                  PopupMenuItem(
                    value: _ProfileAction.adminPanel,
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings_outlined, color: scheme.primary),
                        const SizedBox(width: 10),
                        Text(l10n.homeMenuAdminPanel, style: _menuTextStyle(scheme)),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: _ProfileAction.logout,
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: scheme.error),
                      const SizedBox(width: 10),
                      Text(l10n.homeMenuLogout, style: _menuTextStyle(scheme).copyWith(color: scheme.error)),
                    ],
                  ),
                ),
              ],
              child: Row(
                children: [
                  if (doctorName != null && doctorName!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: isCompact ? 8 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.homeGreeting(doctorName!),
                            style: TextStyle(
                              fontSize: isCompact ? 13 : 15,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (clinicName != null && clinicName!.isNotEmpty)
                            Text(
                              clinicName!,
                              style: TextStyle(
                                fontSize: isCompact ? 11 : 12,
                                color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                              ),
                            ),
                        ],
                      ),
                    ),
                  CircleAvatar(
                    radius: isWide ? 26 : 22,
                    backgroundColor: scheme.primary.withValues(alpha: 0.2),
                    backgroundImage: userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
                    child: userPhotoUrl == null ? Icon(Icons.person, color: scheme.primary) : null,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

TextStyle _menuTextStyle(ColorScheme scheme) {
  return TextStyle(color: scheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.w500);
}

enum _ProfileAction { profile, changeClinic, adminPanel, logout }

enum _LanguageChoice { en, fr, ar }

_FlagType _flagForLocale(String localeName) {
  if (localeName.startsWith('fr')) return _FlagType.france;
  if (localeName.startsWith('ar')) return _FlagType.algeria;
  return _FlagType.england;
}

class _LanguageMenuItem extends StatelessWidget {
  const _LanguageMenuItem({required this.flag, required this.label, required this.isSelected});

  final Widget flag;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      flag,
      const SizedBox(width: 10),
      Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ],
  );
}

enum _FlagType { england, france, algeria }

class _FlagIcon extends StatelessWidget {
  const _FlagIcon({required this.type, this.size = 24});

  final _FlagType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: CustomPaint(painter: _FlagPainter(type)),
      ),
    );
  }
}

class _FlagPainter extends CustomPainter {
  _FlagPainter(this.type);

  final _FlagType type;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case _FlagType.england:
        _paintEngland(canvas, size);
      case _FlagType.france:
        _paintFrance(canvas, size);
      case _FlagType.algeria:
        _paintAlgeria(canvas, size);
    }
  }

  void _paintEngland(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white;
    final red = Paint()..color = const Color(0xFFCE1124);
    canvas.drawRect(Offset.zero & size, white);
    final crossWidth = size.height * 0.28;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width, height: crossWidth),
      red,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: crossWidth, height: size.height),
      red,
    );
  }

  void _paintFrance(Canvas canvas, Size size) {
    final blue = Paint()..color = const Color(0xFF0055A4);
    final white = Paint()..color = Colors.white;
    final red = Paint()..color = const Color(0xFFEF4135);
    final stripe = size.width / 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, stripe, size.height), blue);
    canvas.drawRect(Rect.fromLTWH(stripe, 0, stripe, size.height), white);
    canvas.drawRect(Rect.fromLTWH(stripe * 2, 0, stripe, size.height), red);
  }

  void _paintAlgeria(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF007A3D);
    final white = Paint()..color = Colors.white;
    final red = Paint()..color = const Color(0xFFD21034);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width / 2, size.height), green);
    canvas.drawRect(Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height), white);

    final center = Offset(size.width * 0.52, size.height / 2);
    final outerR = size.height * 0.32;
    final innerR = size.height * 0.26;
    canvas.drawCircle(center, outerR, red);
    canvas.drawCircle(Offset(center.dx + outerR * 0.35, center.dy), innerR, white);

    final starCenter = Offset(size.width * 0.62, size.height / 2);
    _drawStar(canvas, starCenter, size.height * 0.14, red);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 5;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? radius : radius * 0.45;
      final angle = -pi / 2 + (pi / points) * i;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FlagPainter oldDelegate) => oldDelegate.type != type;
}
