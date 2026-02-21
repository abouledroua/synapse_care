import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';
import '../services/cabinet_service.dart';

enum SettingsUsersFilter { waiting, approved, all }

class SettingsUserItem {
  SettingsUserItem({
    required this.userId,
    required this.status,
    required this.role,
    required this.isAdmin,
    required this.isSelf,
    required this.name,
    required this.email,
  });

  final int userId;
  final int status;
  final int role;
  final bool isAdmin;
  final bool isSelf;
  final String name;
  final String email;

  bool get isPending => status == 0;
  bool get isApproved => status == 1;

  static SettingsUserItem fromMap(Map<String, dynamic> raw, {required int currentUserId}) {
    final userId = _asInt(raw['id_user']);
    final email = '${raw['email'] ?? ''}'.trim();
    final fullName = '${raw['fullname'] ?? ''}'.trim();
    return SettingsUserItem(
      userId: userId,
      status: _asInt(raw['status']),
      role: _asInt(raw['role']),
      isAdmin: raw['is_admin'] == true,
      isSelf: userId == currentUserId,
      name: fullName.isEmpty ? (email.isEmpty ? 'ID $userId' : email) : fullName,
      email: email,
    );
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }
}

class SettingsUsersController extends ChangeNotifier {
  SettingsUsersController({CabinetService? service}) : _service = service ?? CabinetService();

  final CabinetService _service;
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  bool isLoading = false;
  bool isActing = false;
  bool isCurrentUserAdmin = false;
  String? errorCode;
  SettingsUsersFilter filter = SettingsUsersFilter.approved;
  List<SettingsUserItem> users = const [];
  bool _defaultFilterApplied = false;

  int? get _cabinetId {
    final raw = AuthController.globalClinic?['id_cabinet'];
    return raw is num ? raw.toInt() : int.tryParse('$raw');
  }

  int? get _userId => AuthController.globalUserId;

  String _stateFromFilter(SettingsUsersFilter value) {
    switch (value) {
      case SettingsUsersFilter.waiting:
        return 'pending';
      case SettingsUsersFilter.approved:
        return 'approved';
      case SettingsUsersFilter.all:
        return 'all';
    }
  }

  Future<void> load({bool clear = false}) async {
    final cabinetId = _cabinetId;
    final userId = _userId;
    if (cabinetId == null || userId == null) {
      users = const [];
      errorCode = 'missing_context';
      notifyListeners();
      return;
    }
    if (clear) {
      users = const [];
    }
    isLoading = true;
    errorCode = null;
    notifyListeners();
    try {
      final result = await _service.fetchCabinetUsers(
        requesterUserId: userId,
        cabinetId: cabinetId,
        state: _stateFromFilter(filter),
        query: searchController.text.trim(),
      );
      isCurrentUserAdmin = result.$1;
      if (!_defaultFilterApplied) {
        _defaultFilterApplied = true;
        final desired = isCurrentUserAdmin ? SettingsUsersFilter.waiting : SettingsUsersFilter.approved;
        if (filter != desired) {
          filter = desired;
          final desiredResult = await _service.fetchCabinetUsers(
            requesterUserId: userId,
            cabinetId: cabinetId,
            state: _stateFromFilter(filter),
            query: searchController.text.trim(),
          );
          isCurrentUserAdmin = desiredResult.$1;
          var desiredMapped = desiredResult.$2
              .map((item) => SettingsUserItem.fromMap(item, currentUserId: userId))
              .where((item) => item.status != 2)
              .toList();
          if (!isCurrentUserAdmin) {
            desiredMapped = desiredMapped.where((item) => item.isApproved).toList();
          }
          users = desiredMapped;
          notifyListeners();
          return;
        }
      }
      var mapped = result.$2
          .map((item) => SettingsUserItem.fromMap(item, currentUserId: userId))
          .where((item) => item.status != 2)
          .toList();
      if (!isCurrentUserAdmin) {
        mapped = mapped.where((item) => item.isApproved).toList();
      }
      users = mapped;
    } catch (e) {
      errorCode = e.toString().toLowerCase().contains('unauthorized') ? 'unauthorized' : 'load_failed';
      users = const [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), load);
  }

  Future<void> setFilter(SettingsUsersFilter next) async {
    if (filter == next) return;
    filter = next;
    notifyListeners();
    await load(clear: true);
  }

  Future<bool> approveUser(int targetUserId) async {
    return _runMemberAction((adminId, cabinetId) {
      return _service.approveCabinetUser(adminUserId: adminId, targetUserId: targetUserId, cabinetId: cabinetId);
    });
  }

  Future<bool> rejectUser(int targetUserId) async {
    return _runMemberAction((adminId, cabinetId) {
      return _service.rejectCabinetUser(adminUserId: adminId, targetUserId: targetUserId, cabinetId: cabinetId);
    });
  }

  Future<CabinetMemberActionResult> grantAdmin(int targetUserId) async {
    return _runMemberActionResult((adminId, cabinetId) {
      return _service.grantCabinetAdmin(adminUserId: adminId, targetUserId: targetUserId, cabinetId: cabinetId);
    });
  }

  Future<CabinetMemberActionResult> revokeAdmin(int targetUserId) async {
    return _runMemberActionResult((adminId, cabinetId) {
      return _service.revokeCabinetAdmin(adminUserId: adminId, targetUserId: targetUserId, cabinetId: cabinetId);
    });
  }

  bool canApprove(SettingsUserItem user) => isCurrentUserAdmin && !isActing && !user.isSelf && user.isPending;

  bool canCancelApproval(SettingsUserItem user) => isCurrentUserAdmin && !isActing && !user.isSelf;

  bool canToggleAdmin(SettingsUserItem user) => isCurrentUserAdmin && !isActing && !user.isSelf && user.isApproved;

  Future<bool> _runMemberAction(
    Future<CabinetMemberActionResult> Function(int adminUserId, int cabinetId) action,
  ) async {
    final result = await _runMemberActionResult(action);
    return result == CabinetMemberActionResult.success;
  }

  Future<CabinetMemberActionResult> _runMemberActionResult(
    Future<CabinetMemberActionResult> Function(int adminUserId, int cabinetId) action,
  ) async {
    final cabinetId = _cabinetId;
    final adminId = _userId;
    if (cabinetId == null || adminId == null) {
      return CabinetMemberActionResult.failed;
    }
    isActing = true;
    notifyListeners();
    try {
      final result = await action(adminId, cabinetId);
      if (result == CabinetMemberActionResult.success) {
        await load();
      }
      return result;
    } finally {
      isActing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
