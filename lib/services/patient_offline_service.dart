import '../core/database/local_database.dart';
import '../core/database/sync_service.dart';

class PatientOfflineService {
  PatientOfflineService({
    required LocalDatabase database,
    required LocalSyncService syncService,
  }) : _database = database,
       _syncService = syncService;

  final LocalDatabase _database;
  final LocalSyncService _syncService;

  Future<void> upsertLocalPatient({
    required int idPatient,
    required String fullName,
    String? phone,
    String? email,
  }) async {
    await _database.replaceLocalPatient(
      idPatient: idPatient,
      fullName: fullName,
      phone: phone,
      email: email,
    );
  }

  Future<void> queueCreatePatient(Map<String, dynamic> payload) {
    return _syncService.enqueue(entity: 'patient', action: 'create', payload: payload);
  }
}
