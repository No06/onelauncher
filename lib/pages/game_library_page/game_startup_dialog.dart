import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/provider/account_provider.dart';
import 'package:one_launcher/provider/game_setting_provider.dart';
import 'package:one_launcher/utils/game_launch_util.dart';
import 'package:one_launcher/widgets/dialog.dart';

typedef _TaskFutureFunction<T> = Future<T>? Function()?;

typedef _TaskDoneCallBack<T> = bool? Function(T)?;

class GameStartupDialog extends ConsumerStatefulWidget {
  const GameStartupDialog({required this.game, super.key});

  final Game game;

  @override
  ConsumerState<GameStartupDialog> createState() => _GameStartupDialogState();
}

class _GameStartupDialogState extends ConsumerState<GameStartupDialog> {
  late final GameLaunchUtil launchUtil;
  Timer? timer;
  int seconds = 5;
  var _continue = false;

  List<String> get warningMessages => launchUtil.warningMessages;

  @override
  void initState() {
    super.initState();
    launchUtil = GameLaunchUtil(widget.game, ref.read(gameSettingProvider));
  }

  @override
  void dispose() {
    timer?.cancel();
    launchUtil.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return warningMessages.isNotEmpty && !_continue
        ? WarningDialog(
            onConfirmed: () => setState(() => _continue = true),
            onCanceled: dialogPop,
            content: SingleChildScrollView(
              child: Text((warningMessages..add('确定要继续吗？')).join('\n')),
            ),
          )
        : DefaultDialog(
            title: const Text("为启动游戏做准备"),
            content: SingleChildScrollView(
              child: _SequenceTaskItems(
                tasks: [
                  _Task(
                    future: launchUtil.retrieveLibraries.toList,
                    title: const Text("检索资源"),
                    onDone: (value) => value.isNotEmpty,
                  ),
                  _Task(
                    future: launchUtil.extractNativesLibraries,
                    title: const Text("解压资源"),
                  ),
                  _Task(
                    future: () => launchUtil
                        .login(ref.read(accountProvider).selectedAccount!),
                    title: const Text("登录"),
                    onDone: (value) => true,
                  ),
                  _Task(
                    future: launchUtil.launchGame,
                    title: const Text("启动"),
                  ),
                ],
              ),
            ),
            onlyConfirm: true,
            onConfirmed: () async {
              if (!launchUtil.completer.isCompleted) {
                // 强制关闭
                await launchUtil.cancel();
                launchUtil.killProcess();
              }
              dialogPop();
            },
            confirmText: FutureBuilder(
              future: launchUtil.completer.future,
              builder: (context, snapshot) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        timer == null) {
                      seconds -= 1;
                      timer = Timer.periodic(Durations.extralong4, (time) {
                        if (seconds > 0) {
                          setState(() => seconds--);
                          if (seconds == 0) {
                            // 关闭 Process 并关闭窗口
                            Future.delayed(Durations.extralong4, dialogPop);
                          }
                        }
                      });
                    }
                    return Text("取消${timer != null ? ' ($seconds)' : ''}");
                  },
                );
              },
            ),
          );
  }
}

/// 顺序执行任务
class _SequenceTaskItems<T> extends StatefulWidget {
  const _SequenceTaskItems({required this.tasks});

  final List<_Task<T>> tasks;

  @override
  State<_SequenceTaskItems<T>> createState() => _SequenceTaskItemsState<T>();
}

class _SequenceTaskItemsState<T> extends State<_SequenceTaskItems<T>> {
  final listenables = <ValueNotifier<_TaskFutureFunction<T>>>[];
  final futures = <_TaskFutureFunction<T>>[];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.tasks.length; i++) {
      final currentTask = widget.tasks[i];
      final next = i + 1;
      final nextTask = widget.tasks.elementAtOrNull(next);
      // 跳过第一个
      if (i != 0) {
        listenables.add(ValueNotifier(null));
      }
      // 串联 Future
      futures.add(
        currentTask.future == null
            ? null
            : () => currentTask.future!()!.then(
                  (value) {
                    // 当还有下一个任务时
                    if (currentTask.onDone != null) {
                      currentTask.hasError = currentTask.onDone!(value);
                    }
                    if (nextTask != null && !(currentTask.hasError ?? false)) {
                      listenables[i].value = futures[next];
                    }
                    return value;
                  },
                ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(widget.tasks.length, (index) {
        final task = widget.tasks[index];
        if (index == 0) {
          return _TaskItem(task, future: futures[index]);
        }
        return ValueListenableBuilder(
          valueListenable: listenables[index - 1],
          builder: (context, value, child) => _TaskItem(task, future: value),
        );
      }),
    );
  }
}

class _Task<T> {
  _Task({
    required this.title,
    this.future,
    this.onDone,
    this.hasError,
  });

  final _TaskFutureFunction<T> future;
  final Widget title;
  final _TaskDoneCallBack<T> onDone;
  bool? hasError;
}

class _TaskItem<T> extends StatelessWidget {
  const _TaskItem(this.task, {this.future});

  final _Task<T> task;
  final _TaskFutureFunction<T>? future;

  final _errorIconColor = Colors.red;
  final _doneIconColor = Colors.green;
  final _height = 32.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: FutureBuilder(
        future: future == null ? null : future!(),
        builder: (context, snapshot) {
          final state = snapshot.connectionState;
          return Row(
            children: [
              SizedBox.square(
                dimension: _height,
                child: Center(
                  child: () {
                    switch (state) {
                      case ConnectionState.none:
                        return const Icon(Icons.hourglass_empty);
                      case ConnectionState.waiting || ConnectionState.active:
                        return const CircularProgressIndicator();
                      case ConnectionState.done:
                        if (task.hasError ?? false) {
                          return Icon(Icons.error, color: _errorIconColor);
                        }
                        return Icon(Icons.done, color: _doneIconColor);
                    }
                  }(),
                ),
              ),
              const SizedBox(width: 8),
              task.title,
            ],
          );
        },
      ),
    );
  }
}
