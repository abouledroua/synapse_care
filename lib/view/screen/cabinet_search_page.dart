import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cabinet_search_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constant/layout_constants.dart';
import '../../services/cabinet_service.dart';
import '../widget/input_card.dart';
import '../widget/app_background.dart';

class CabinetSearchPage extends StatefulWidget {
  const CabinetSearchPage({super.key});

  @override
  State<CabinetSearchPage> createState() => _CabinetSearchPageState();
}

class _CabinetSearchPageState extends State<CabinetSearchPage> {
  final CabinetSearchController _controller = CabinetSearchController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= LayoutConstants.wideBreakpoint;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final visibleResults = _controller.results.where((item) {
          final rawEtat = item['etat'];
          final etat = rawEtat is num ? rawEtat.toInt() : int.tryParse('$rawEtat') ?? 1;
          return etat != 2;
        }).toList();
        return Scaffold(
          body: Stack(
            children: [
              const AppBackground(),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Text(
                          l10n.cabinetSearchTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isWide ? 26 : 22,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () async {
                                  final refreshed = await context.push<bool>('/cabinet/create');
                                  if (refreshed == true) {
                                    _controller.search(_controller.searchController.text);
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: Text(l10n.cabinetSearchAddNew),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () => _controller.search(_controller.searchController.text),
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.patientListRefresh),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InputCard(
                          icon: Icons.search,
                          hintText: l10n.cabinetSearchHint,
                          keyboardType: TextInputType.text,
                          controller: _controller.searchController,
                          textInputAction: TextInputAction.search,
                          onChanged: _controller.search,
                          onSubmitted: _controller.search,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.cabinetSearchHelper,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant.withValues(alpha: 0.65)),
                        ),
                        const SizedBox(height: 18),
                        if (_controller.isLoading)
                          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CircularProgressIndicator())
                        else if (_controller.errorCode != null)
                          Text(l10n.loginNetworkError, style: TextStyle(color: scheme.error))
                        else if (visibleResults.isEmpty)
                          Text(
                            l10n.cabinetSearchEmpty,
                            style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: visibleResults.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = visibleResults[index];
                              final name = (item['nom_cabinet'] ?? '').toString();
                              final specialty = (item['specialite_cabinet'] ?? '').toString();
                              final address = (item['adresse_cabinet'] ?? '').toString();
                              final photoFile = (item['photo_url'] ?? '').toString();
                              final cabinetId = int.tryParse('${item['id_cabinet'] ?? ''}');
                              final imageUrl = _controller.cabinetImageUrl(photoFile);
                              final rawEtat = item['etat'];
                              final etat = rawEtat is num ? rawEtat.toInt() : int.tryParse('$rawEtat') ?? 1;
                              final clinicValidated = etat == 1;
                              final clinicStatusText = clinicValidated
                                  ? null
                                  : (etat == 2 ? l10n.cabinetStatusRejected : l10n.cabinetStatusPending);
                              final cardBackground = clinicValidated
                                  ? scheme.surface.withValues(alpha: 0.92)
                                  : (Color.lerp(scheme.surface, scheme.primary, 0.12) ?? scheme.surface);
                              return InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: cabinetId == null || _controller.submittingId == cabinetId
                                    ? null
                                    : () async {
                                        if (!clinicValidated) {
                                          final message = etat == 2
                                              ? l10n.cabinetSelectRejectedToast
                                              : l10n.cabinetSelectPendingToast;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(message)),
                                          );
                                          return;
                                        }
                                        final result = await _controller.assignCabinet(cabinetId);
                                        if (!context.mounted) return;
                                        final messenger = ScaffoldMessenger.of(context);
                                        if (result == CabinetAssignResult.success) {
                                          messenger.showSnackBar(SnackBar(content: Text(l10n.cabinetRequestSent)));
                                          if (context.canPop()) {
                                            context.pop(true);
                                          } else {
                                            context.go('/cabinet/select');
                                          }
                                        } else if (result == CabinetAssignResult.clinicNotValidated) {
                                          messenger.showSnackBar(SnackBar(content: Text(l10n.cabinetSelectPendingToast)));
                                        } else if (result == CabinetAssignResult.exists) {
                                          messenger.showSnackBar(SnackBar(content: Text(l10n.cabinetRequestExists)));
                                        } else if (result == CabinetAssignResult.network) {
                                          messenger.showSnackBar(SnackBar(content: Text(l10n.loginNetworkError)));
                                        } else {
                                          messenger.showSnackBar(SnackBar(content: Text(l10n.cabinetRequestFailed)));
                                        }
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: cardBackground,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundColor: scheme.primary.withValues(alpha: 0.15),
                                        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                                        child: imageUrl == null
                                            ? Icon(Icons.local_hospital_outlined, color: scheme.primary)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name.isEmpty ? l10n.cabinetSelectUnnamed : name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: scheme.onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              specialty.isEmpty ? l10n.cabinetSelectSampleSpecialty : specialty,
                                              style: TextStyle(
                                                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                                                fontSize: 13,
                                              ),
                                            ),
                                            if (address.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                address,
                                                style: TextStyle(
                                                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (_controller.submittingId == cabinetId)
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
                                        )
                                      else
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (clinicStatusText != null) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: scheme.primary.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
                                                ),
                                                child: Text(
                                                  clinicStatusText,
                                                  style: TextStyle(
                                                    color: scheme.primary,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            if (clinicValidated)
                                              Icon(Icons.add, color: scheme.primary.withValues(alpha: 0.8)),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
      },
    );
  }
}
