import 'package:flutter/widgets.dart';

List<Widget> buildWidgetsWithDivider(List<Widget> widgets, Widget divider) {
  for (int i = 1; i < widgets.length; i += 2) {
    widgets.insert(i, divider);
  }
  return widgets;
}

extension ListExtension<T> on List<T> {
  List<T> joinWith(T obj) {
    for (int i = 1; i < length; i += 2) {
      insert(i, obj);
    }
    return this;
  }
}
