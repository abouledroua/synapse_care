import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../controller/auth_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../services/cabinet_service.dart';
import '../widget/app_background.dart';

class AdminClinicValidationPage extends StatefulWidget {
  const AdminClinicValidationPage({super.key});

  @override
  State<AdminClinicValidationPage> createState() => _AdminClinicValidationPageState();
}

class _AdminClinicValidationPageState extends State<AdminClinicValidationPage> {
  final CabinetService _service = CabinetService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _loading = true;
  bool _listLoading = false;
  bool _busyAction = false;
  String? _error;
  List<Map<String, dynamic>> _clinics = [];
  String _selectedState = 'pending';

  @override
  void initState() {
    super.initState();
    _load(fullScreen: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool fullScreen = false}) async {
    final userId = AuthController.globalUserId;
    if (userId == null) {
      setState(() {
        _loading = false;
        _listLoading = false;
        _error = 'unauthorized';
      });
      return;
    }
    setState(() {
      if (fullScreen) {
        _loading = true;
      } else {
        _listLoading = true;
      }
      _error = null;
    });
    try {
      final rows = await _service.fetchPlatformCabinets(
        adminUserId: userId,
        state: _selectedState,
        query: _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _clinics = rows;
        _loading = false;
        _listLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _listLoading = false;
        _error = e.toString().contains('unauthorized') ? 'unauthorized' : 'network';
      });
    }
  }

  Future<void> _review({
    required int cabinetId,
    required bool approve,
  }) async {
    final userId = AuthController.globalUserId;
    final l10n = AppLocalizations.of(context)!;
    if (userId == null) return;
    setState(() => _busyAction = true);
    final result = approve
        ? await _service.approveCabinet(adminUserId: userId, cabinetId: cabinetId)
        : await _service.rejectCabinet(adminUserId: userId, cabinetId: cabinetId);
    if (!mounted) return;
    setState(() => _busyAction = false);
    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case CabinetReviewResult.success:
        messenger.showSnackBar(
          SnackBar(content: Text(approve ? l10n.adminClinicsApproveSuccess : l10n.adminClinicsRejectSuccess)),
        );
        await _load();
        break;
      case CabinetReviewResult.unauthorized:
        messenger.showSnackBar(SnackBar(content: Text(l10n.adminClinicsUnauthorized)));
        break;
      case CabinetReviewResult.failed:
      case CabinetReviewResult.network:
        messenger.showSnackBar(SnackBar(content: Text(l10n.adminClinicsActionFailed)));
        break;
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
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
    if (!mounted || shouldLogout != true) return;
    final controller = AuthController();
    controller.logout();
    context.go('/auth/login');
  }

  String _formatCreatedAt(dynamic raw) {
    if (raw == null) return '-';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return raw.toString();
    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _titleForState(AppLocalizations l10n) {
    switch (_selectedState) {
      case 'all':
        return l10n.adminClinicsTitleAll;
      case 'approved':
        return l10n.adminClinicsTitleApproved;
      case 'canceled':
        return l10n.adminClinicsTitleCanceled;
      default:
        return l10n.adminClinicsTitlePending;
    }
  }

  String _statusLabelForItem(AppLocalizations l10n, Map<String, dynamic> item) {
    if (_selectedState == 'approved') return l10n.adminClinicsApproved;
    if (_selectedState == 'canceled') return l10n.adminClinicsCanceled;
    if (_selectedState == 'pending') return l10n.adminClinicsPending;
    final rawEtat = item['etat'];
    final etat = rawEtat is num ? rawEtat.toInt() : int.tryParse('$rawEtat') ?? 0;
    if (etat == 1) return l10n.adminClinicsApproved;
    if (etat == 2) return l10n.adminClinicsCanceled;
    return l10n.adminClinicsPending;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width >= LayoutConstants.wideBreakpoint;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
        title: Text(_titleForState(l10n)),
        centerTitle: true,
        actions: [
          if (isWide)
            TextButton.icon(
              onPressed: _loading || _listLoading || _busyAction ? null : () => _load(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.adminClinicsRefresh),
            )
          else
            IconButton(
              onPressed: _loading || _listLoading || _busyAction ? null : () => _load(),
              icon: const Icon(Icons.refresh),
              tooltip: l10n.adminClinicsRefresh,
            ),
          if (isWide)
            TextButton.icon(
              onPressed: _busyAction ? null : _logout,
              icon: Icon(Icons.logout, color: scheme.error),
              label: Text(l10n.homeMenuLogout, style: TextStyle(color: scheme.error)),
            )
          else
            IconButton(
              onPressed: _busyAction ? null : _logout,
              icon: Icon(Icons.logout, color: scheme.error),
              tooltip: l10n.homeMenuLogout,
            ),
        ],
      ),
        body: Stack(
        children: [
          const AppBackground(),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error == 'unauthorized')
            Center(
              child: Text(l10n.adminClinicsUnauthorized, style: TextStyle(color: scheme.error)),
            )
          else
            RefreshIndicator(
              onRefresh: () => _load(),
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(const Duration(milliseconds: 350), () => _load());
                    },
                    decoration: InputDecoration(
                      hintText: l10n.adminClinicsSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        showCheckmark: false,
                        backgroundColor: const Color(0xFFF4F4F4),
                        selectedColor: const Color(0xFFE5E7EB),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.layerGroup,
                              size: 17,
                              color: _selectedState == 'all' ? const Color(0xFF374151) : const Color(0xFF8A8A8A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.adminClinicsAll,
                              style: TextStyle(
                                color: _selectedState == 'all' ? const Color(0xFF374151) : null,
                                fontWeight: _selectedState == 'all' ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        selected: _selectedState == 'all',
                        onSelected: (selected) {
                          if (!selected) return;
                          setState(() => _selectedState = 'all');
                          _load();
                        },
                      ),
                      ChoiceChip(
                        showCheckmark: false,
                        backgroundColor: const Color(0xFFF4F4F4),
                        selectedColor: const Color(0xFFFFE8A3),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.hourglassHalf,
                              size: 17,
                              color: _selectedState == 'pending' ? const Color(0xFF7A5A00) : const Color(0xFF8A8A8A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.adminClinicsPending,
                              style: TextStyle(
                                color: _selectedState == 'pending' ? const Color(0xFF7A5A00) : null,
                                fontWeight: _selectedState == 'pending' ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        selected: _selectedState == 'pending',
                        onSelected: (selected) {
                          if (!selected) return;
                          setState(() => _selectedState = 'pending');
                          _load();
                        },
                      ),
                      ChoiceChip(
                        showCheckmark: false,
                        backgroundColor: const Color(0xFFF4F4F4),
                        selectedColor: const Color(0xFFD9F7E4),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.circleCheck,
                              size: 17,
                              color: _selectedState == 'approved' ? const Color(0xFF0F6B3A) : const Color(0xFF8A8A8A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.adminClinicsApproved,
                              style: TextStyle(
                                color: _selectedState == 'approved' ? const Color(0xFF0F6B3A) : null,
                                fontWeight: _selectedState == 'approved' ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        selected: _selectedState == 'approved',
                        onSelected: (selected) {
                          if (!selected) return;
                          setState(() => _selectedState = 'approved');
                          _load();
                        },
                      ),
                      ChoiceChip(
                        showCheckmark: false,
                        backgroundColor: const Color(0xFFF4F4F4),
                        selectedColor: const Color(0xFFFFDFDF),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.circleXmark,
                              size: 17,
                              color: _selectedState == 'canceled' ? const Color(0xFF9A1F1F) : const Color(0xFF8A8A8A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.adminClinicsCanceled,
                              style: TextStyle(
                                color: _selectedState == 'canceled' ? const Color(0xFF9A1F1F) : null,
                                fontWeight: _selectedState == 'canceled' ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        selected: _selectedState == 'canceled',
                        onSelected: (selected) {
                          if (!selected) return;
                          setState(() => _selectedState = 'canceled');
                          _load();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_listLoading) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 10),
                  ],
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(l10n.loginNetworkError, style: TextStyle(color: scheme.error)),
                    ),
                  if (_clinics.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          l10n.adminClinicsEmpty,
                          style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.8)),
                        ),
                      ),
                    ),
                  if (_clinics.isNotEmpty)
                  ...List.generate(_clinics.length, (index) {
                  final item = _clinics[index];
                  final name = (item['nom_cabinet'] ?? '').toString().trim();
                  final specialty = (item['specialite_cabinet'] ?? '').toString().trim();
                  final address = (item['adresse_cabinet'] ?? '').toString().trim();
                  final photoFile = (item['photo_url'] ?? '').toString().trim();
                  final imageUrl = _service.cabinetPhotoUrl(photoFile);
                  final creatorName = (item['creator_name'] ?? '').toString().trim();
                  final createdAtText = _formatCreatedAt(item['created_at_text'] ?? item['created_at']);
                  final cabinetId = int.tryParse('${item['id_cabinet'] ?? ''}');
                  final rawEtat = item['etat'];
                  final etat = rawEtat is num ? rawEtat.toInt() : int.tryParse('$rawEtat') ?? 0;
                  final canReview = etat == 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: scheme.primary.withValues(alpha: 0.12),
                              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                              child: imageUrl == null ? Icon(Icons.local_hospital_outlined, color: scheme.primary) : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.isEmpty ? l10n.cabinetSelectUnnamed : name,
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
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
                                  const SizedBox(height: 4),
                                  Text(
                                    '${l10n.adminClinicsCreatedBy}: ${creatorName.isEmpty ? '-' : creatorName}',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${l10n.adminClinicsCreatedAt}: $createdAtText',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _statusLabelForItem(l10n, item),
                                style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        if ((_selectedState == 'pending' || _selectedState == 'all') && canReview) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _busyAction || cabinetId == null
                                      ? null
                                      : () => _review(cabinetId: cabinetId, approve: false),
                                  child: Text(l10n.adminClinicsReject),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _busyAction || cabinetId == null
                                      ? null
                                      : () => _review(cabinetId: cabinetId, approve: true),
                                  child: Text(l10n.adminClinicsApprove),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                  }).expand((w) => [w, const SizedBox(height: 10)]),
                ],
              ),
            ),
        ],
        ),
      ),
    );
  }
}
