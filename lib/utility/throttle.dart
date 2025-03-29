// lib/core/utils/throttle.dart
import 'dart:async';

class Throttler {
  final Duration delay;
  Timer? _timer;
  
  Throttler({required this.delay});
  
  void run(Function action) {
    if (_timer == null || !_timer!.isActive) {
      action();
      _timer = Timer(delay, () {});
    }
  }
  
  void dispose() {
    _timer?.cancel();
  }
}