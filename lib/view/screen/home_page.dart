import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/home_controller.dart';
import '../../controller/auth_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../core/utils/patient_formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../services/patient_service.dart';
import '../widget/home_dashboard.dart';
import '../widget/home_quick_actions.dart';
import '../widget/home_top_bar.dart';
import '../widget/app_background.dart';
import '../widget/app_footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final HomeController _controller = HomeController();
  final GlobalKey _searchBarKey = GlobalKey();
  final GlobalKey _dashboardStackKey = GlobalKey();
  Rect? _searchBarRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.startClock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.stopClock();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.loadPatientCount();
      _controller.loadTodayAppointmentCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= LayoutConstants.wideBreakpoint;
    final isCompact = size.width < LayoutConstants.wideBreakpoint;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final searchBar = _HomeSearchBar(
      key: _searchBarKey,
      scheme: scheme,
      l10n: l10n,
      isCompact: isCompact,
      controller: _controller.searchController,
      onChanged: _controller.searchPatients,
      isSearching: _controller.isSearching,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSearchBarRect());
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                              HomeTopBar(
                              dateText: _controller.formatDate(),
                              timeText: _controller.formatTime(),
                              scheme: scheme,
                              l10n: l10n,
                              isWide: isWide,
                              doctorName: _controller.doctorName(),
                              clinicName: _controller.clinicName(),
                                userPhotoUrl: _controller.userPhotoUrl(),
                                isPlatformAdmin: AuthController.isPlatformAdmin,
                                searchBar: isCompact ? null : searchBar,
                                onChangeClinic: _handleChangeClinic,
                              ),
                            if (isCompact) ...comptactWidget(searchBar, l10n, context, scheme),
                            (isWide)
                                ? HomeQuickActions(
                                    l10n: l10n,
                                    scheme: scheme,
                                    onPatientsTap: () => context.push('/patients/list'),
                                    onConsultationTap: () => context.push('/consultations'),
                                    onRdvTap: () => context.push('/appointments/list'),
                                    onSettingsTap: () => context.push('/settings'),
                                  )
                                : const SizedBox(height: 8),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      key: _dashboardStackKey,
                                      children: [
                                        HomeDashboard(
                                          scheme: scheme,
                                          isWide: isWide,
                                          l10n: l10n,
                                          patientCount: _controller.patientCount,
                                          todayAppointmentCount:
                                              _controller.todayAppointmentCount,
                                          nextTodayAppointment:
                                              _controller.nextTodayAppointment,
                                        ),
                                        if (_controller.searchController.text.trim().isNotEmpty)
                                          Positioned(
                                            left: _panelLeft(size.width, min(size.width, 800)),
                                            top: 0,
                                            width: min(size.width, 800),
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

  List<Widget> comptactWidget(
    _HomeSearchBar searchBar,
    AppLocalizations l10n,
    BuildContext context,
    ColorScheme scheme,
  ) {
    return [
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: searchBar),
          const SizedBox(width: 10),
          PopupMenuButton<_QuickActionKey>(
            position: PopupMenuPosition.under,
            offset: const Offset(0, 6),
            color: Colors.white.withValues(alpha: 0.96),
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _QuickActionKey.patients,
                child: _QuickActionMenuItem(
                  label: l10n.homeMenuPatientsList,
                  icon: Icons.people_alt_outlined,
                  color: const Color(0xFF1F8A70),
                ),
              ),
              PopupMenuItem(
                value: _QuickActionKey.consultations,
                child: _QuickActionMenuItem(
                  label: l10n.homeMenuConsultation,
                  icon: Icons.medical_information_outlined,
                  color: const Color(0xFF3F6BB6),
                ),
              ),
              PopupMenuItem(
                value: _QuickActionKey.rdv,
                child: _QuickActionMenuItem(
                  label: l10n.homeMenuRdvList,
                  icon: Icons.event_available_outlined,
                  color: const Color(0xFFE39B27),
                ),
              ),
              PopupMenuItem(
                value: _QuickActionKey.caisse,
                child: _QuickActionMenuItem(
                  label: l10n.homeMenuCaisse,
                  icon: Icons.point_of_sale_outlined,
                  color: const Color(0xFF2D6A9F),
                ),
              ),
              PopupMenuItem(
                value: _QuickActionKey.settings,
                child: _QuickActionMenuItem(
                  label: l10n.homeMenuSettings,
                  icon: Icons.settings_outlined,
                  color: const Color(0xFF8E3B46),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case _QuickActionKey.patients:
                  context.push('/patients/list');
                  break;
                case _QuickActionKey.consultations:
                  context.push('/consultations');
                  break;
                case _QuickActionKey.rdv:
                  context.push('/appointments/list');
                  break;
                case _QuickActionKey.caisse:
                  break;
                case _QuickActionKey.settings:
                  context.push('/settings');
                  break;
              }
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(0, 8))],
              ),
              child: Icon(Icons.grid_view_rounded, color: scheme.primary),
            ),
          ),
        ],
      ),
    ];
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

  Future<void> _handleChangeClinic() async {
    _controller.clearDashboardData();
    if (!mounted) return;
    await context.push('/cabinet/select');
    if (!mounted) return;
    _controller.refreshDashboardDataNow();
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({
    super.key,
    required this.scheme,
    required this.l10n,
    required this.isCompact,
    required this.controller,
    required this.onChanged,
    required this.isSearching,
  });

  final ColorScheme scheme;
  final AppLocalizations l10n;
  final bool isCompact;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final searchHeight = isCompact ? 50.0 : 58.0;
    final searchPadding = isCompact ? 12.0 : 18.0;
    final hintSize = isCompact ? 14.0 : 16.0;

    return Container(
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
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: hintSize),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: l10n.homeSearchHint,
                hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: hintSize),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox(width: 4);
              }
              return IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: Icon(Icons.clear, color: scheme.primary),
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                splashRadius: 18,
              );
            },
          ),
          Container(width: 1, height: 24, color: scheme.onSurfaceVariant.withValues(alpha: 0.2)),
          const SizedBox(width: 10),
          if (isSearching)
            SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary))
          else
            Icon(Icons.search, color: scheme.primary),
        ],
      ),
    );
  }
}

enum _QuickActionKey { patients, consultations, rdv, caisse, settings }

class _QuickActionMenuItem extends StatelessWidget {
  const _QuickActionMenuItem({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
        ),
      ],
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
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = results[index];
              final nom = (item['nom'] ?? '').toString();
              final prenom = (item['prenom'] ?? '').toString();
              final tel = PatientFormatters.formatPhone(item['tel1']);
              final email = (item['email'] ?? '').toString();
              final photoFile = (item['photo_url'] ?? '').toString();
              final imageUrl = PatientService().patientPhotoUrl(photoFile);
              final displayName = '${prenom.isEmpty ? '' : '$prenom '}$nom'.trim();
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                    backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl == null ? Icon(Icons.person_outline, color: scheme.primary) : null,
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
