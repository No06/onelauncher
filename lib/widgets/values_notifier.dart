import 'package:flutter/foundation.dart';

class ValuesNotifier implements ValueListenable<bool> {
  ValuesNotifier(this.valueListenables) {
    listenable = Listenable.merge(valueListenables);
    listenable.addListener(onNotified);
  }
  final List<ValueListenable> valueListenables;
  late final Listenable listenable;
  bool val = false;

  @override
  void addListener(VoidCallback listener) {
    listenable.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listenable.removeListener(listener);
  }

  @override
  bool get value => val;

  void onNotified() {
    val = !val;
  }
}
