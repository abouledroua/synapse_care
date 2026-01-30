import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/synapse_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _menuOpen = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {},
      child: Scaffold(
        body: Stack(
          children: [
            const SynapseBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    if (_menuOpen) _SideMenu(l10n: l10n, scheme: scheme),
                    if (_menuOpen) const SizedBox(width: 22),
                    Expanded(
                      child: Column(
                        children: [
                          _TopBar(
                            dateText: _formatDate(DateTime.now()),
                            scheme: scheme,
                            l10n: l10n,
                            isWide: isWide,
                            menuOpen: _menuOpen,
                            onToggleMenu: () => setState(() => _menuOpen = !_menuOpen),
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: scheme.surface.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.dateText,
    required this.scheme,
    required this.l10n,
    required this.isWide,
    required this.menuOpen,
    required this.onToggleMenu,
  });

  final String dateText;
  final ColorScheme scheme;
  final AppLocalizations l10n;
  final bool isWide;
  final bool menuOpen;
  final VoidCallback onToggleMenu;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: onToggleMenu, icon: Icon(menuOpen ? Icons.menu_open : Icons.menu), color: scheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
            ),
            child: Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 12),
                Text(
                  l10n.homeSearchHint,
                  style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 16),
                ),
                const Spacer(),
                Container(width: 1, height: 28, color: scheme.onSurfaceVariant.withValues(alpha: 0.2)),
                const SizedBox(width: 12),
                Icon(Icons.search, color: scheme.primary),
              ],
            ),
          ),
        ),
        const SizedBox(width: 18),
        Text(dateText, style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 16)),
        const SizedBox(width: 18),
        PopupMenuButton<_ProfileAction>(
          position: PopupMenuPosition.under,
          offset: const Offset(0, 8),
          color: Colors.white.withValues(alpha: 0.96),
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (value) {
            switch (value) {
              case _ProfileAction.profile:
                // TODO: navigate to profile page when available.
                break;
              case _ProfileAction.changeClinic:
                context.push('/cabinet/select');
                break;
              case _ProfileAction.logout:
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
            PopupMenuItem(
              value: _ProfileAction.logout,
              child: Row(
                children: [
                  Icon(Icons.logout, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(l10n.homeMenuLogout, style: _menuTextStyle(scheme)),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            radius: isWide ? 26 : 22,
            backgroundColor: scheme.primary.withValues(alpha: 0.2),
            backgroundImage: _userPhotoUrl() != null ? NetworkImage(_userPhotoUrl()!) : null,
            child: _userPhotoUrl() == null ? Icon(Icons.person, color: scheme.primary) : null,
          ),
        ),
      ],
    );
  }

  String? _userPhotoUrl() {
    final user = AuthController.globalUser;
    if (user == null) return null;
    final photo = (user['photo_url'] ?? '').toString();
    if (photo.isEmpty) return null;
    final baseUrl = AuthController.resolveApiBaseUrl();
    return '$baseUrl/photos/$photo';
  }
}

TextStyle _menuTextStyle(ColorScheme scheme) {
  return TextStyle(color: scheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.w500);
}

enum _ProfileAction { profile, changeClinic, logout }

class _SideMenu extends StatelessWidget {
  const _SideMenu({required this.l10n, required this.scheme});

  final AppLocalizations l10n;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: 0.96), scheme.primaryContainer.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 22, offset: Offset(0, 12))],
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: ScrollConfiguration(
        behavior: const _MenuScrollBehavior(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MenuItem(
                icon: Icons.newspaper_outlined,
                label: l10n.homeMenuConsultation,
                scheme: scheme,
                isPrimary: true,
              ),
              _MenuItem(icon: Icons.history, label: l10n.homeMenuHistory, scheme: scheme),
              _MenuItem(icon: Icons.point_of_sale_outlined, label: l10n.homeMenuCaisse, scheme: scheme),
              _MenuItem(icon: Icons.settings_outlined, label: l10n.homeMenuSettings, scheme: scheme),
              _MenuItem(icon: Icons.storage_outlined, label: l10n.homeMenuData, scheme: scheme),
              _MenuItem(icon: Icons.info_outline, label: l10n.homeMenuAbout, scheme: scheme),
              _MenuItem(icon: Icons.event_available_outlined, label: l10n.homeMenuToday, scheme: scheme),
              _MenuItem(icon: Icons.event_note_outlined, label: l10n.homeMenuRdvTake, scheme: scheme),
              _MenuItem(icon: Icons.list_alt_outlined, label: l10n.homeMenuRdvList, scheme: scheme),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuScrollBehavior extends MaterialScrollBehavior {
  const _MenuScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.scheme, this.isPrimary = false});

  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Icon(icon, color: scheme.primary.withValues(alpha: isPrimary ? 0.95 : 0.7)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant.withValues(alpha: isPrimary ? 0.95 : 0.85),
            fontSize: isPrimary ? 17 : 16,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ],
    ),
  );
}
