import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';
import '../../controller/home_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/synapse_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final GlobalKey _searchBarKey = GlobalKey();
  final GlobalKey _dashboardStackKey = GlobalKey();
  Rect? _searchBarRect;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _controller.startClock();
  }

  @override
  void dispose() {
    _controller.stopClock();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSearchBarRect());
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => PopScope(
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
                      if (_controller.menuOpen) _SideMenu(l10n: l10n, scheme: scheme),
                      if (_controller.menuOpen) const SizedBox(width: 22),
                      Expanded(
                        child: Column(
                          children: [
                            _TopBar(
                              dateText: _controller.formatDate(),
                              timeText: _controller.formatTime(),
                              scheme: scheme,
                              l10n: l10n,
                              isWide: isWide,
                              menuOpen: _controller.menuOpen,
                              onToggleMenu: _controller.toggleMenu,
                              doctorName: _controller.doctorName(),
                              clinicName: _controller.clinicName(),
                              userPhotoUrl: _controller.userPhotoUrl(),
                              searchController: _controller.searchController,
                              onSearchChanged: _controller.searchPatients,
                              isSearching: _controller.isSearching,
                              searchBarKey: _searchBarKey,
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: Stack(
                                key: _dashboardStackKey,
                                children: [
                                  _Dashboard(scheme: scheme, isWide: isWide, l10n: l10n),
                                  if (_controller.searchController.text.trim().isNotEmpty)
                                    Positioned(
                                      left: _panelLeft(size.width, min(size.width, 600)),
                                      top: 0,
                                      width: min(size.width, 600),
                                      child: _PatientSearchPanel(
                                        scheme: scheme,
                                        l10n: l10n,
                                        isSearching: _controller.isSearching,
                                        error: _controller.searchError,
                                        results: _controller.searchResults,
                                        maxHeight: size.height * 0.32,
                                        scrollController: _controller.searchScrollController,
                                      ),
                                    ),
                                ],
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
      ),
    );
  }

  void _updateSearchBarRect() {
    final searchContext = _searchBarKey.currentContext;
    final stackContext = _dashboardStackKey.currentContext;
    if (searchContext == null || stackContext == null) return;
    final searchBox = searchContext.findRenderObject() as RenderBox?;
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (searchBox == null || stackBox == null || !searchBox.hasSize || !stackBox.hasSize) return;
    final searchTopLeft = searchBox.localToGlobal(Offset.zero);
    final localTopLeft = stackBox.globalToLocal(searchTopLeft);
    final rect = Rect.fromLTWH(localTopLeft.dx, localTopLeft.dy, searchBox.size.width, searchBox.size.height);
    if (_searchBarRect == rect) return;
    setState(() => _searchBarRect = rect);
  }

  double _panelLeft(double screenWidth, double panelWidth) {
    final rect = _searchBarRect;
    if (rect == null) return 0;
    final desired = rect.center.dx - panelWidth / 2;
    return desired.clamp(0.0, screenWidth - panelWidth);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.dateText,
    required this.timeText,
    required this.scheme,
    required this.l10n,
    required this.isWide,
    required this.menuOpen,
    required this.onToggleMenu,
    required this.doctorName,
    required this.clinicName,
    required this.userPhotoUrl,
    required this.searchController,
    required this.onSearchChanged,
    required this.isSearching,
    required this.searchBarKey,
  });

  final String dateText;
  final String timeText;
  final ColorScheme scheme;
  final AppLocalizations l10n;
  final bool isWide;
  final bool menuOpen;
  final VoidCallback onToggleMenu;
  final String? doctorName;
  final String? clinicName;
  final String? userPhotoUrl;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool isSearching;
  final GlobalKey searchBarKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final searchHeight = isCompact ? 50.0 : 58.0;
        final searchPadding = isCompact ? 12.0 : 18.0;
        final hintSize = isCompact ? 14.0 : 16.0;

        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: scheme.primary.withValues(alpha: 0.8)),
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
                    Icon(Icons.access_time, size: 14, color: scheme.primary.withValues(alpha: 0.7)),
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
            const SizedBox(width: 10),
            IconButton(
              onPressed: onToggleMenu,
              icon: Icon(menuOpen ? Icons.menu_open : Icons.menu),
              color: scheme.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                key: searchBarKey,
                height: searchHeight,
                padding: EdgeInsets.symmetric(horizontal: searchPadding),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: hintSize),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: l10n.homeSearchHint,
                          hintStyle: TextStyle(
                            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                            fontSize: hintSize,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: scheme.onSurfaceVariant.withValues(alpha: 0.2)),
                    const SizedBox(width: 10),
                    if (isSearching)
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
                      )
                    else
                      Icon(Icons.search, color: scheme.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                      Icon(Icons.logout, color: scheme.error),
                      const SizedBox(width: 10),
                      Text(l10n.homeMenuLogout, style: _menuTextStyle(scheme).copyWith(color: scheme.error)),
                    ],
                  ),
                ),
              ],
              child: Row(
                children: [
                  if (!isCompact && doctorName != null && doctorName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.homeGreeting(doctorName!),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                          ),
                          if (clinicName != null && clinicName!.isNotEmpty)
                            Text(
                              clinicName!,
                              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant.withValues(alpha: 0.65)),
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

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.scheme, required this.isWide, required this.l10n});

  final ColorScheme scheme;
  final bool isWide;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const dashboardPadding = 16.0;
            const spacing = 10.0;
            const minCardWidth = 260.0;
            final available = max(0.0, constraints.maxWidth - (dashboardPadding * 2));
            final rawColumns = ((available + spacing) / (minCardWidth + spacing)).floor();
            final columns = max(1, min(3, rawColumns));
            var cardWidth = (available - spacing * (columns - 1)) / columns;
            cardWidth -= dashboardPadding / 2;
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(dashboardPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.surface.withValues(alpha: 0.55), scheme.primaryContainer.withValues(alpha: 0.18)],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 26, offset: Offset(0, 14))],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -60,
                    top: -40,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [scheme.primary.withValues(alpha: 0.18), Colors.transparent]),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeDashboardTitle,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: isWide ? 26 : 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          _DashCard(
                            width: cardWidth,
                            scheme: scheme,
                            title: l10n.homeDashAppointments,
                            value: '12',
                            icon: Icons.event_available_outlined,
                            accent: scheme.primary,
                          ),
                          _DashCard(
                            width: cardWidth,
                            scheme: scheme,
                            title: l10n.homeDashConsultationsToday,
                            value: '8',
                            icon: Icons.medical_information_outlined,
                            accent: scheme.primary,
                          ),
                          _DashCard(
                            width: cardWidth,
                            scheme: scheme,
                            title: l10n.homeDashPatients,
                            value: '86',
                            icon: Icons.people_alt_outlined,
                            accent: scheme.secondary,
                          ),
                          _DashCard(
                            width: cardWidth,
                            scheme: scheme,
                            title: l10n.homeDashRevenue,
                            value: '2.4k',
                            icon: Icons.account_balance_wallet_outlined,
                            accent: scheme.tertiary,
                          ),
                          _DashCard(
                            width: cardWidth,
                            scheme: scheme,
                            title: l10n.homeDashAlerts,
                            value: '3',
                            icon: Icons.notifications_active_outlined,
                            accent: scheme.error,
                          ),
                          _DashCard(
                            width: cardWidth,
                            scheme: scheme,
                            title: l10n.homeDashConsultationsMonth,
                            value: '128',
                            icon: Icons.assessment_outlined,
                            accent: scheme.secondary,
                          ),
                          _DashWideCard(
                            width: available,
                            scheme: scheme,
                            title: l10n.homeDashNextTitle,
                            subtitle: l10n.homeDashNextSubtitle,
                            icon: Icons.schedule_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PatientSearchPanel extends StatelessWidget {
  const _PatientSearchPanel({
    required this.scheme,
    required this.l10n,
    required this.isSearching,
    required this.error,
    required this.results,
    required this.maxHeight,
    required this.scrollController,
  });

  final ColorScheme scheme;
  final AppLocalizations l10n;
  final bool isSearching;
  final String? error;
  final List<Map<String, dynamic>> results;
  final double maxHeight;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const SizedBox(height: 8);
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(l10n.loginNetworkError, style: TextStyle(color: scheme.error)),
      );
    }
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          l10n.homePatientSearchEmpty,
          style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: ListView.separated(
            controller: scrollController,
            primary: false,
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = results[index];
              final nom = (item['nom'] ?? '').toString();
              final prenom = (item['prenom'] ?? '').toString();
              final tel = (item['tel1'] ?? '').toString();
              final email = (item['email'] ?? '').toString();
              final displayName = '${prenom.isEmpty ? '' : '$prenom '}$nom'.trim();
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.person_outline, color: scheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isEmpty ? l10n.homePatientSearchUnnamed : displayName,
                          style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tel.isNotEmpty ? tel : email,
                          style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.65), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: scheme.primary.withValues(alpha: 0.6)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.width,
    required this.scheme,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final double width;
  final ColorScheme scheme;
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: accent.withValues(alpha: 0.9)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashWideCard extends StatelessWidget {
  const _DashWideCard({
    required this.width,
    required this.scheme,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final double width;
  final ColorScheme scheme;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary.withValues(alpha: 0.15), scheme.surface.withValues(alpha: 0.12)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
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
              _MenuItem(icon: Icons.newspaper_outlined, label: l10n.homeMenuConsultation, scheme: scheme),
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
  const _MenuItem({required this.icon, required this.label, required this.scheme});

  final IconData icon;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Icon(icon, color: scheme.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ],
    ),
  );
}
