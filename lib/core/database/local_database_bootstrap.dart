import 'local_database.dart';

class LocalDatabaseBootstrap {
  LocalDatabaseBootstrap._();

  static final LocalDatabase instance = LocalDatabase();
  static bool _ready = false;

  static Future<void> ensureReady() async {
    if (_ready) return;
    // Drift opens lazily on first real query; keeping bootstrap lightweight.
    _ready = true;
  }
}
