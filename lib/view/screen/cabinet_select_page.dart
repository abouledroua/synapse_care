import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cabinet_select_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../services/cabinet_service.dart';
import '../widget/app_background.dart';

class CabinetSelectPage extends StatefulWidget {
  const CabinetSelectPage({super.key});

  @override
  State<CabinetSelectPage> createState() => _CabinetSelectPageState();
}

class _CabinetSelectPageState extends State<CabinetSelectPage> {
  final CabinetSelectController _controller = CabinetSelectController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        final filteredCabinets = _controller.cabinets.where((item) {
          final rawEtat = item['etat'];
          final etat = rawEtat is num ? rawEtat.toInt() : int.tryParse('$rawEtat') ?? 0;
          final rawStatus = item['status'];
          final status = rawStatus is num ? rawStatus.toInt() : int.tryParse('$rawStatus') ?? 0;
          return etat != 2 && status != 2;
        }).toList();
        return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {},
        child: Scaffold(
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
                            l10n.cabinetSelectTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isWide ? 26 : 22,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.cabinetSelectBody,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    final refreshed = await context.push<bool>('/cabinet/search');
                                    if (refreshed == true) {
                                      await _controller.load();
                                    }
                                  },
                                  icon: const Icon(Icons.search_rounded),
                                  label: Text(l10n.cabinetSelectFind),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: _controller.isLoading ? null : _controller.load,
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.patientListRefresh),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  side: BorderSide(color: scheme.primary.withValues(alpha: 0.6)),
                                  foregroundColor: scheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(color: scheme.onSurfaceVariant.withValues(alpha: 0.2)),
                          const SizedBox(height: 10),
                          if (_controller.isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(),
                            )
                          else if (_controller.errorCode != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                l10n.loginNetworkError,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: scheme.error),
                              ),
                            )
                          else if (filteredCabinets.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                l10n.cabinetSelectEmpty,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredCabinets.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = filteredCabinets[index];
                                final name = (item['nom_cabinet'] ?? '').toString();
                                final specialty = (item['specialite_cabinet'] ?? '').toString();
                                final photoFile = (item['photo_url'] ?? '').toString();
                                final imageUrl = _controller.cabinetImageUrl(photoFile);
                                final cabinetId = int.tryParse('${item['id_cabinet'] ?? ''}');
                                final rawStatus = item['status'];
                                final status = rawStatus is num ? rawStatus.toInt() : int.tryParse('$rawStatus') ?? 0;
                                final rawEtat = item['etat'];
                                final etat = rawEtat is num ? rawEtat.toInt() : int.tryParse('$rawEtat') ?? 0;
                                final clinicValidated = etat == 1;
                                final isApproved = status == 1 && clinicValidated;
                                final statusText = etat == 2
                                    ? l10n.cabinetStatusRejected
                                    : (!clinicValidated || status == 0
                                        ? l10n.cabinetStatusPending
                                        : (status == 2 ? l10n.cabinetStatusRejected : null));
                                return _CabinetCard(
                                  name: name.isEmpty ? l10n.cabinetSelectUnnamed : name,
                                  specialty: specialty.isEmpty ? l10n.cabinetSelectSampleSpecialty : specialty,
                                  imageUrl: imageUrl,
                                  statusText: statusText,
                                  onTap: () {
                                    if (!isApproved) {
                                      final message = etat == 2 || status == 2
                                          ? l10n.cabinetSelectRejectedToast
                                          : l10n.cabinetSelectPendingToast;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                                      return;
                                    }
                                    _controller.selectCabinet(item);
                                    context.go('/home');
                                  },
                                  onRemove: cabinetId == null
                                      ? null
                                      : () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (dialogContext) => AlertDialog(
                                              title: Text(l10n.cabinetRemoveConfirmTitle),
                                              content: Text(l10n.cabinetRemoveConfirmBody),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                                  child: Text(l10n.cabinetRemoveCancel),
                                                ),
                                                FilledButton(
                                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                                  child: Text(l10n.cabinetRemoveConfirm),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed != true) return;

                                          final result = await _controller.removeCabinet(cabinetId);
                                          if (!context.mounted) return;
                                          final messenger = ScaffoldMessenger.of(context);
                                          if (result == CabinetRemoveResult.success) {
                                            messenger.showSnackBar(SnackBar(content: Text(l10n.cabinetRemoveSuccess)));
                                          } else if (result == CabinetRemoveResult.lastAdmin) {
                                            messenger.showSnackBar(
                                              SnackBar(content: Text(l10n.cabinetRemoveLastAdminError)),
                                            );
                                          } else if (result == CabinetRemoveResult.network) {
                                            messenger.showSnackBar(SnackBar(content: Text(l10n.loginNetworkError)));
                                          } else {
                                            messenger.showSnackBar(SnackBar(content: Text(l10n.cabinetRemoveFailed)));
                                          }
                                        },
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
        ),
      );
      },
    );
  }
}

class _CabinetCard extends StatelessWidget {
  const _CabinetCard({
    required this.name,
    required this.specialty,
    required this.onTap,
    this.onRemove,
    this.imageUrl,
    this.statusText,
  });

  final String name;
  final String specialty;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final String? imageUrl;
  final String? statusText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.primary.withValues(alpha: 0.15),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null ? Icon(Icons.local_hospital_outlined, color: scheme.primary) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          specialty,
                          style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13),
                        ),
                      ),
                      if (statusText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            statusText!,
                            style: TextStyle(color: scheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.remove_circle_outline, color: scheme.error),
                tooltip: AppLocalizations.of(context)!.cabinetRemoveAction,
              )
            else
              Icon(Icons.chevron_right, color: scheme.primary.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}
