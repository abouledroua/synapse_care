import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_database.dart';
import 'local_database_bootstrap.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) => LocalDatabaseBootstrap.instance);
