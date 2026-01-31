import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controller/home_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/home_dashboard.dart';
import '../widget/home_quick_actions.dart';
import '../widget/home_top_bar.dart';
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
                              searchController: _controller.searchController,
                              onSearchChanged: _controller.searchPatients,
                              isSearching: _controller.isSearching,
                              searchBarKey: _searchBarKey,
                            ),
                            const SizedBox(height: 10),
                            HomeQuickActions(l10n: l10n, scheme: scheme),
                            const SizedBox(height: 18),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      key: _dashboardStackKey,
                                      children: [
                                        HomeDashboard(scheme: scheme, isWide: isWide, l10n: l10n),
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
