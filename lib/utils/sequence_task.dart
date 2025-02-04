import 'dart:ui';

class SequenceTask {
  SequenceTask({
    required this.tasks,
    this.onTaskStart,
    this.onTaskDone,
    this.onTaskError,
    this.onFinished,
  });

  final List<Task> tasks;
  final void Function(int index)? onTaskStart;
  final void Function(int index, Task task, Object? result)? onTaskDone;
  final void Function(int index, Task task, Object error)? onTaskError;
  final VoidCallback? onFinished;
  var _started = false;
  bool get started => _started;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      onTaskStart?.call(i);
      try {
        final result = await task.future;
        final isDone = task.onDone(result) ?? true;
        onTaskDone?.call(i, task, result);
        if (!isDone) break;
      } catch (e, s) {
        final shouldContinue = task.onError(e, s) ?? false;
        onTaskError?.call(i, task, e);
        if (!shouldContinue) break;
        return;
      }
    }

    onFinished?.call();
    _started = false;
  }
}

class Task<T> {
  Task({
    required this.name,
    required Future<T> Function() futureFunction,
    bool Function(T result)? onDone,
    bool Function(Object error, StackTrace stack)? onError,
  })  : _futureFunction = futureFunction,
        _onDone = onDone,
        _onError = onError;

  final String name;

  Future<T>? _future;
  final Future<T> Function() _futureFunction;
  Future<T> get future => _future ??= _futureFunction();

  var _isDone = false;
  bool get isDone => _isDone;

  /// Return false to stop the sequence
  final bool Function(T result)? _onDone;
  bool? onDone(T result) {
    _isDone = true;
    return _onDone?.call(result);
  }

  Object? _error;
  bool get hasError => _error != null;

  /// Return false to stop the sequence
  final bool Function(Object error, StackTrace stack)? _onError;
  bool? onError(Object error, StackTrace stack) {
    _error = error;
    return _onError?.call(error, stack);
  }
}
