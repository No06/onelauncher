import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class ReadWriteValueNotifier<T> extends ReadWriteValue<T>
    with ChangeNotifier
    implements ValueListenable<T> {
  ReadWriteValueNotifier(
    super.key,
    super.defaultValue, [
    super.getBox,
  ]);

  @override
  set val(T newVal) {
    super.val = newVal;
    notifyListeners();
  }

  @override
  T get value => super.val;
}
