import 'dart:async';

import 'package:flutter/foundation.dart';

class TimeoutController extends ChangeNotifier {
  Timer? _timer;

  void start({required Duration duration, required VoidCallback onTimeout}) {
    _timer?.cancel();
    _timer = Timer(duration, onTimeout);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
