import 'dart:convert';

import 'local_database.dart';

typedef SyncHandler = Future<void> Function({
  required String entity,
  required String action,
  required Map<String, dynamic> payload,
});

class LocalSyncService {
  LocalSyncService(this._db);

  final LocalDatabase _db;

  Future<void> enqueue({
    required String entity,
    required String action,
    required Map<String, dynamic> payload,
  }) => _db.enqueueSync(entity: entity, action: action, payloadJson: jsonEncode(payload));

  Future<void> flushPending(SyncHandler handler) async {
    final items = await _db.pendingSyncItems();
    for (final item in items) {
      try {
        final decoded = jsonDecode(item.payloadJson);
        final payload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
        await handler(entity: item.entity, action: item.action, payload: payload);
        await _db.markSyncDone(item.id);
      } catch (e) {
        await _db.markSyncFailed(item.id, e.toString());
      }
    }
  }
}
