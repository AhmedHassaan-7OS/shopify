import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  Debouncer({this.delay = defaultDelay});

  static const Duration defaultDelay = Duration(milliseconds: 400);

  final Duration delay;

  Timer? _timer;

  bool get isActive => _timer?.isActive ?? false;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}
