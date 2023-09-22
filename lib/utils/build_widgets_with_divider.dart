import 'package:flutter/widgets.dart';

List<Widget> buildWidgetsWithDivider(List<Widget> widgets, Widget divider) {
  for (int i = 1; i < widgets.length; i += 2) {
    widgets.insert(i, divider);
  }
  return widgets;
}
