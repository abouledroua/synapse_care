import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../controller/settings_users_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../services/cabinet_service.dart';
import 'settings_group_title.dart';

class SettingsUsersGroup extends StatefulWidget {
  const SettingsUsersGroup({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  State<SettingsUsersGroup> createState() => _SettingsUsersGroupState();
}

class _SettingsUsersGroupState extends State<SettingsUsersGroup> {
  late final SettingsUsersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsUsersController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsGroupTitle(title: l10n.settingsGroupUsers),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller.searchController,
                    onChanged: _controller.onSearchChanged,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.settingsUsersSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: scheme.surface.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _controller.isLoading ? null : _controller.load,
                  tooltip: l10n.adminClinicsRefresh,
                  icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_controller.isCurrentUserAdmin)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.settingsUsersFilterWaiting),
                      selected: _controller.filter == SettingsUsersFilter.waiting,
                      onSelected: (_) => _controller.setFilter(SettingsUsersFilter.waiting),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(l10n.settingsUsersFilterApproved),
                      selected: _controller.filter == SettingsUsersFilter.approved,
                      onSelected: (_) => _controller.setFilter(SettingsUsersFilter.approved),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(l10n.settingsUsersFilterAll),
                      selected: _controller.filter == SettingsUsersFilter.all,
                      onSelected: (_) => _controller.setFilter(SettingsUsersFilter.all),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            if (_controller.isLoading)
              const Center(
                child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
              )
            else if (_controller.errorCode != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _controller.errorCode == 'unauthorized'
                      ? l10n.settingsUsersUnauthorized
                      : l10n.settingsUsersLoadFailed,
                  style: TextStyle(color: scheme.error),
                ),
              )
            else if (_controller.users.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.settingsUsersEmpty, style: TextStyle(color: scheme.onSurfaceVariant)),
              )
            else
              ..._controller.users.map((item) => _buildUserTile(context, l10n, item)),
          ],
        );
      },
    );
  }

  Widget _buildUserTile(BuildContext context, AppLocalizations l10n, SettingsUserItem item) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                if (item.isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.settingsUsersAdminBadge,
                      style: TextStyle(color: scheme.primary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            if (item.email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(item.email, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 4),
            Text(
              '${l10n.settingsUsersRoleLabel}: ${_roleLabel(l10n, item.role)} • ${l10n.settingsUsersStatusLabel}: ${_statusLabel(l10n, item.status)}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            if (_controller.isCurrentUserAdmin) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.isPending)
                    FilledButton.tonalIcon(
                      onPressed: _controller.canApprove(item) ? () => _onApproveUser(item.userId) : null,
                      icon: const FaIcon(FontAwesomeIcons.userCheck, size: 14),
                      label: Text(l10n.settingsUsersApprove),
                    ),
                  FilledButton.tonalIcon(
                    onPressed: _controller.canCancelApproval(item) ? () => _onCancelApproval(item.userId) : null,
                    icon: const FaIcon(FontAwesomeIcons.userXmark, size: 14),
                    label: Text(l10n.settingsUsersCancelApproval),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _controller.canToggleAdmin(item)
                        ? () => _onToggleAdmin(item.userId, item.isAdmin)
                        : null,
                    icon: FaIcon(item.isAdmin ? FontAwesomeIcons.userMinus : FontAwesomeIcons.userShield, size: 14),
                    label: Text(item.isAdmin ? l10n.settingsUsersUnmakeAdmin : l10n.settingsUsersMakeAdmin),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _roleLabel(AppLocalizations l10n, int role) {
    if (role == 1) return l10n.doctor;
    if (role == 2) return l10n.assistant;
    return l10n.patient;
  }

  String _statusLabel(AppLocalizations l10n, int status) {
    if (status == 1) return l10n.settingsUsersFilterApproved;
    if (status == 2) return l10n.adminClinicsCanceled;
    return l10n.settingsUsersFilterWaiting;
  }

  Future<void> _onApproveUser(int userId) async {
    final confirmed = await _showActionConfirmDialog(
      title: widget.l10n.settingsUsersApproveConfirmTitle,
      body: widget.l10n.settingsUsersApproveConfirmBody,
    );
    if (!confirmed) return;
    final l10n = widget.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _controller.approveUser(userId);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? l10n.settingsUsersActionSuccess : l10n.settingsUsersActionFailed)),
    );
  }

  Future<void> _onCancelApproval(int userId) async {
    final confirmed = await _showActionConfirmDialog(
      title: widget.l10n.settingsUsersCancelConfirmTitle,
      body: widget.l10n.settingsUsersCancelConfirmBody,
    );
    if (!confirmed) return;
    final l10n = widget.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _controller.rejectUser(userId);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? l10n.settingsUsersActionSuccess : l10n.settingsUsersActionFailed)),
    );
  }

  Future<void> _onToggleAdmin(int userId, bool isAdmin) async {
    final l10n = widget.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final result = isAdmin ? await _controller.revokeAdmin(userId) : await _controller.grantAdmin(userId);
    if (!mounted) return;
    final message = result == CabinetMemberActionResult.success
        ? l10n.settingsUsersActionSuccess
        : (result == CabinetMemberActionResult.lastAdmin
              ? l10n.cabinetRemoveLastAdminError
              : l10n.settingsUsersActionFailed);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _showActionConfirmDialog({required String title, required String body}) async {
    final l10n = widget.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.patientOptionNo)),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.patientOptionYes)),
          ],
        );
      },
    );
    return result == true;
  }
}
