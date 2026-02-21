import 'package:flutter/material.dart';

import '../../controller/clinic_log_controller.dart';
import '../../l10n/app_localizations.dart';

class ClinicLogList extends StatelessWidget {
  const ClinicLogList({super.key, required this.controller});

  final ClinicLogController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null) {
      final isUnauthorized = controller.error!.toLowerCase().contains('unauthorized');
      return Center(
        child: Text(
          isUnauthorized ? l10n.accessDeniedBody : l10n.loginNetworkError,
          style: TextStyle(color: scheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (controller.logs.isEmpty) {
      return Center(
        child: Text(
          l10n.appointmentListEmpty,
          style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.75)),
        ),
      );
    }
    return ListView.separated(
      itemCount: controller.logs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = controller.logs[index];
        final action = '${item['action_type'] ?? '-'}'.toUpperCase();
        final table = '${item['table_name'] ?? '-'}';
        final rowId = '${item['row_id'] ?? '-'}';
        final createdAt = '${item['created_at'] ?? ''}';
        final userId = '${item['id_user'] ?? '-'}';
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$action • $table', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
              const SizedBox(height: 4),
              Text('row: $rowId | user: $userId', style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(createdAt, style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.8), fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}
