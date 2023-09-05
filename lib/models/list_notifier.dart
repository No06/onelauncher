import 'package:flutter/foundation.dart';

// 定义一个ListNotifier类，它继承自ChangeNotifier类
class ListNotifier<T> extends ChangeNotifier {
  // 定义一个私有的列表变量
  late List<T> _list;

  // 定义一个构造函数，接受一个初始列表作为参数
  ListNotifier(List<T>? initialList) {
    _list = initialList ?? []; // 如果初始列表为空，就赋值一个空列表
  }

  // 定义一个getter方法，返回当前的列表
  List<T> get list => _list;

  // 定义一个setter方法，设置当前的列表，并通知监听者
  set list(List<T> newList) {
    _list = newList;
    notifyListeners();
  }

  // 定义一个添加元素的方法，并通知监听者
  void add(T element) {
    _list.add(element);
    notifyListeners();
  }

  // 定义一个移除元素的方法，并通知监听者
  void remove(T element) {
    _list.remove(element);
    notifyListeners();
  }

  // 定义一个清空列表的方法，并通知监听者
  void clear() {
    _list.clear();
    notifyListeners();
  }

  // 定义其他的列表操作方法，根据需要通知监听者
}
