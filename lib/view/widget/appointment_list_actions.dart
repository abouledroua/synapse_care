import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class AppointmentListActions extends StatelessWidget {
  const AppointmentListActions({
    super.key,
    required this.loading,
    required this.onRefresh,
    required this.onAdd,
  });

  final bool loading;
  final Future<void> Function() onRefresh;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.homeMenuRdvTake),
          ),
          OutlinedButton.icon(
            onPressed: loading ? null : onRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.patientListRefresh),
          ),
        ],
      ),
    );
  }
}
