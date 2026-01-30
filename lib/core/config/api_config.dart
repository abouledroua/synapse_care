import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  static String resolveBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3001';
    }
    if (Platform.isAndroid) {
      return 'http://amor-pc.local:3001';
    }
    return 'http://localhost:3001';
  }
}
