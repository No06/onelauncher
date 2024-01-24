import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/utils/game_launch_util.dart';
import 'package:one_launcher/widgets/dialog.dart';

typedef _TaskFutureFunction<T> = Future<T>? Function()?;

typedef _TaskDoneCallBack<T> = void Function(
    AsyncSnapshot<T> snapshot, bool? hasError)?;

class GameStartupDialog extends StatelessWidget {
  GameStartupDialog({super.key, required this.game})
      : launchUtil = GameLaunchUtil(game);

  final Game game;
  final GameLaunchUtil launchUtil;

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: const Text("为启动游戏做准备"),
      content: SingleChildScrollView(
        child: _SequenceTaskItems(
          tasks: [
            _Task(
              future: launchUtil.retrieveLibraries.toList,
              title: const Text("检索游戏资源"),
              onDone: (snapshot, hasError) {
                if (snapshot.data!.isNotEmpty) {
                  hasError = true;
                }
              },
            ),
            _Task(
              future: () => launchUtil.login(appConfig.selectedAccount!),
              title: const Text("登录"),
              onDone: (snapshot, hasError) {
                if (snapshot.data == null) {
                  hasError = true;
                }
              },
            ),
            // TODO: 待测试
            _Task(
              // future: launchUtil.extractNativesLibrary,
              future: () => Future(() => null),
              title: const Text("解压资源包"),
            ),
          ],
        ),
      ),
      onlyConfirm: true,
      onConfirmed: dialogPop,
      confirmText: const Text("取消"),
    );
  }
}

/// 顺序执行任务
class _SequenceTaskItems extends StatelessWidget {
  _SequenceTaskItems({required this.tasks});

  final List<_Task> tasks;
  final listenables = <ValueNotifier<_TaskFutureFunction>>[];
  final futures = <_TaskFutureFunction>[];

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < tasks.length; i++) {
      final currentTaskFuture = tasks[i].future;
      final next = i + 1;
      final nextTask = tasks.elementAtOrNull(next);
      // 跳过第一个
      if (i != 0) {
        listenables.add(ValueNotifier(null));
      }
      // 串联 Future
      futures.add(
        currentTaskFuture == null
            ? null
            : () => currentTaskFuture()!.then(
                  (value) {
                    // 当还有下一个任务时
                    if (nextTask != null) {
                      listenables[i].value = futures[next];
                    }
                    return value;
                  },
                ),
      );
    }

    return Column(
      children: List<Widget>.generate(tasks.length, (index) {
        final task = tasks[index];
        if (index == 0) {
          return _TaskItem(
            title: task.title,
            future: futures[index],
            onDone: task.onDone,
            hasError: task.hasError,
          );
        }
        return ValueListenableBuilder(
          valueListenable: listenables[index - 1],
          builder: (context, value, child) => _TaskItem(
            title: task.title,
            future: value,
            onDone: task.onDone,
            hasError: task.hasError,
          ),
        );
      }),
    );
  }
}

class _Task<T> {
  const _Task({
    this.future,
    required this.title,
    this.onDone,
    this.hasError,
  });

  final _TaskFutureFunction<T> future;
  final Widget title;
  final _TaskDoneCallBack<T> onDone;
  final bool? hasError;
}

class _TaskItem<T> extends StatelessWidget {
  const _TaskItem({
    this.future,
    required this.title,
    this.onDone,
    this.hasError,
  });

  final _TaskFutureFunction<T> future;
  final Widget title;
  final _TaskDoneCallBack<T> onDone;
  final bool? hasError;

  static const _errorIconColor = Colors.red;
  static const _doneIconColor = Colors.green;
  static const _height = 32.0;

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
                  child: Builder(builder: (context) {
                    switch (state) {
                      case ConnectionState.none:
                        return const Icon(Icons.hourglass_empty);
                      case ConnectionState.waiting || ConnectionState.active:
                        return const CircularProgressIndicator();
                      case ConnectionState.done:
                        if (onDone != null) {
                          onDone!(snapshot, hasError);
                        }
                        if (hasError ?? false) {
                          return const Icon(Icons.error,
                              color: _errorIconColor);
                        }
                        return const Icon(Icons.done, color: _doneIconColor);
                    }
                  }),
                ),
              ),
              const SizedBox(width: 8),
              title,
            ],
          );
        },
      ),
    );
  }
}
