import 'dart:async';

/// for debouncing
///
/// example:
/// ```dart
/// final debouncer = Debouncer(const Duration(milliseconds: 500));
/// debouncer.run(() {
///  print('debounced'); // this will be called after 500ms of the last call
/// });
/// ```
class Debouncer {
  Debouncer(this.duration);

  final Duration duration;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }
}
