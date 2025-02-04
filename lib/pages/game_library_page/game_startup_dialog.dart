import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/models/account/account_login_info.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/provider/account_provider.dart';
import 'package:one_launcher/provider/game_setting_provider.dart';
import 'package:one_launcher/utils/game_launcher.dart';
import 'package:one_launcher/utils/sequence_task.dart';
import 'package:one_launcher/widgets/dialog.dart';

class GameStartupDialog extends ConsumerStatefulWidget {
  const GameStartupDialog({required this.game, super.key});

  final Game game;

  @override
  ConsumerState<GameStartupDialog> createState() => _GameStartupDialogState();
}

class _GameStartupDialogState extends ConsumerState<GameStartupDialog> {
  late final GameLauncher _launcher;
  static const _timeout = 5;
  var _continue = false;
  late final ValueNotifier<(Timer?, int)> _timeoutNotifier;

  @override
  void initState() {
    super.initState();
    _launcher = GameLauncher(
      game: widget.game,
      globalSetting: ref.read(gameSettingProvider),
    );
    _timeoutNotifier = ValueNotifier<(Timer?, int)>((null, _timeout));
  }

  @override
  void dispose() {
    final (timer, _) = _timeoutNotifier.value;
    timer?.cancel();
    _timeoutNotifier.dispose();
    super.dispose();
  }

  void _setCloseTimeout() {
    var (timer, timeout) = _timeoutNotifier.value;
    if (timer != null) return;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final isTimeout = timer.tick > _timeout - 1;
      if (isTimeout) {
        timer.cancel();
        context.pop();
      } else {
        timeout = _timeout - 1 - timer.tick;
        _timeoutNotifier.value = (timer, timeout);
      }
    });
    _timeoutNotifier.value = (timer, timeout - 1);
  }

  @override
  Widget build(BuildContext context) {
    if (!_continue) {
      final warningMessages = _launcher.checkSettings();
      if (warningMessages.isNotEmpty) {
        return WarningDialog(
          onConfirmed: () => setState(() => _continue = true),
          onCanceled: routePop,
          content: SingleChildScrollView(
            child: Text((warningMessages..add('确定要继续吗？')).join('\n')),
          ),
        );
      }
    }

    AccountLoginInfo? loginInfo;
    return DefaultDialog(
      title: const Text("为启动游戏做准备"),
      content: SingleChildScrollView(
        child: _SequenceTaskList(
          onFinished: _setCloseTimeout,
          onTaskError: (index, task, error) {
            context.pop();
            showDialog<void>(
              context: context,
              builder: (context) => ErrorDialog(
                title: const Text("启动失败"),
                content: Text("任务 [${task.name}] 失败: $error"),
                onConfirmed: routePop,
              ),
            );
          },
          tasks: [
            Task(
              name: "检索资源",
              futureFunction: () => _launcher.retrieveLibraries,
              onDone: (value) => value.nonExistenceLibraries.isEmpty,
            ),
            Task(
              name: "解压资源",
              futureFunction: _launcher.extractUnavaliableNativesLibraries,
            ),
            Task(
              name: "登录",
              futureFunction: () async {
                final account = ref.read(accountProvider).selectedAccount!;
                loginInfo = await account.login();
              },
            ),
            Task(
              name: "启动",
              futureFunction: () => _launcher.launch(loginInfo!),
            ),
          ],
        ),
      ),
      onlyConfirm: true,
      onConfirmed: () {
        _launcher.cancelLaunch();
        routePop();
      },
      confirmText: ValueListenableBuilder(
        valueListenable: _timeoutNotifier,
        builder: (context, value, child) {
          final (timer, timeout) = value;
          if (timer == null) return const Text("取消");
          return Text("取消 ($timeout)");
        },
      ),
    );
  }
}

class _SequenceTaskList<T> extends StatefulWidget {
  const _SequenceTaskList({
    required this.tasks,
    this.onTaskStart,
    this.onTaskDone,
    this.onTaskError,
    this.onFinished,
  });

  final List<Task<T>> tasks;
  final void Function(int index)? onTaskStart;
  final void Function(int index, Task task, Object? result)? onTaskDone;
  final void Function(int index, Task task, Object error)? onTaskError;
  final VoidCallback? onFinished;

  @override
  State<_SequenceTaskList> createState() => _SequenceTaskListState();
}

class _SequenceTaskListState extends State<_SequenceTaskList> {
  var _currentTaskIndex = -1;

  @override
  void initState() {
    super.initState();
    SequenceTask(
      tasks: widget.tasks,
      onTaskStart: _onTaskStart,
      onTaskDone: _onTaskDone,
      onTaskError: _onTaskError,
      onFinished: _onFinished,
    ).start();
  }

  void _onTaskStart(int index) {
    widget.onTaskStart?.call(index);
    setState(() {
      _currentTaskIndex = index;
    });
  }

  void _onTaskDone(int index, Task task, Object? result) {
    widget.onTaskDone?.call(index, task, result);
  }

  void _onTaskError(int index, Task task, Object error) {
    widget.onTaskError?.call(index, task, error);
  }

  void _onFinished() {
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(widget.tasks.length, (index) {
        final task = widget.tasks[index];
        final future = _currentTaskIndex >= index ? task.future : null;
        return _TaskItem(task: task, future: future);
      }),
    );
  }
}

class _TaskItem<T> extends StatelessWidget {
  const _TaskItem({required this.task, this.future});

  final Task<T> task;
  final Future<T>? future;

  static const _errorIconColor = Colors.red;
  static const _doneIconColor = Colors.green;
  static const _height = 32.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          final state = snapshot.connectionState;
          final hasError = snapshot.hasError || task.hasError;
          return Row(
            spacing: 8,
            children: [
              SizedBox.square(
                dimension: _height,
                child: Center(
                  child: switch (state) {
                    ConnectionState.none => const Icon(Icons.hourglass_empty),
                    ConnectionState.waiting ||
                    ConnectionState.active =>
                      const CircularProgressIndicator(
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ConnectionState.done => hasError
                        ? const Icon(Icons.error, color: _errorIconColor)
                        : const Icon(Icons.done, color: _doneIconColor),
                  },
                ),
              ),
              Text(task.name),
            ],
          );
        },
      ),
    );
  }
}
