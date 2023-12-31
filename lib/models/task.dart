import 'package:flutter/widgets.dart';

class Task<T> {
  Task(this.function, {this.name, this.finished}); // 任务状态

  final String? name; // 任务名
  final Future<T> function; // 任务函数，返回一个Future<String>
  final void Function()? finished; // 执行完毕回调函数
  ConnectionState _state = ConnectionState.waiting; // 任务状态

  Future<T> run() async {
    _state = ConnectionState.active;
    return await function;
  }

  ConnectionState get state => _state;
}
