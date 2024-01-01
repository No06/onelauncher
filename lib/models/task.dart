import 'package:flutter/widgets.dart';

class Task<T> {
  Task(this.name, this.function); // 任务状态

  final String name; // 任务名
  final Function() function; // 任务函数，返回一个Future<String>
  ConnectionState _state = ConnectionState.waiting; // 任务状态

  Future<void> run() async {
    _state = ConnectionState.active;
    await function();
    _state = ConnectionState.done;
  }

  ConnectionState get state => _state;
}
