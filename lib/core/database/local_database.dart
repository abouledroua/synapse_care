import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'local_database.g.dart';

class LocalPatients extends Table {
  IntColumn get idPatient => integer()();
  TextColumn get fullName => text().withDefault(const Constant(''))();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {idPatient};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get action => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [LocalPatients, SyncQueue])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> replaceLocalPatient({
    required int idPatient,
    required String fullName,
    String? phone,
    String? email,
  }) async {
    await into(localPatients).insertOnConflictUpdate(
      LocalPatientsCompanion(
        idPatient: Value(idPatient),
        fullName: Value(fullName),
        phone: Value(phone),
        email: Value(email),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> enqueueSync({
    required String entity,
    required String action,
    required String payloadJson,
  }) async => into(syncQueue).insert(
    SyncQueueCompanion.insert(entity: entity, action: action, payloadJson: payloadJson),
  );

  Future<List<SyncQueueData>> pendingSyncItems({int limit = 50}) {
    final query = (select(syncQueue)
      ..where((t) => t.status.equals('pending'))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
      ..limit(limit));
    return query.get();
  }

  Future<void> markSyncDone(int id) async {
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('done'),
        updatedAt: Value(DateTime.now()),
        lastError: const Value(null),
      ),
    );
  }

  Future<void> markSyncFailed(int id, String error) async {
    await customUpdate(
      '''
      UPDATE sync_queue
      SET status = 'pending',
          retry_count = retry_count + 1,
          last_error = ?,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
      ''',
      variables: [Variable.withString(error), Variable.withInt(id)],
      updates: {syncQueue},
    );
  }
}

QueryExecutor _openConnection() => driftDatabase(name: 'curatio_local');
