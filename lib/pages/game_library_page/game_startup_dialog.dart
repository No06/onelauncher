import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/utils/game_launch_util.dart';
import 'package:one_launcher/widgets/dialog.dart';

typedef _TaskFutureFunction<T> = Future<T>? Function()?;

typedef _TaskDoneCallBack<T> = FutureOr Function(
    AsyncSnapshot<T> snapshot, bool? hasError)?;

class GameStartupDialog extends StatefulWidget {
  GameStartupDialog({super.key, required this.game})
      : launchUtil = GameLaunchUtil(game);

  final Game game;
  final GameLaunchUtil launchUtil;

  @override
  State<GameStartupDialog> createState() => _GameStartupDialogState();
}

class _GameStartupDialogState extends State<GameStartupDialog> {
  late final List<String> warningMessages;
  final completer = Completer();
  StreamSubscription? subscription;
  StreamSubscription? errSubscription;
  Process? process;
  Timer? timer;
  var seconds = 2;
  var _continue = false;

  @override
  void initState() {
    super.initState();
    warningMessages = widget.launchUtil.warningMessages;
  }

  @override
  void dispose() {
    timer?.cancel();
    subscription?.cancel();
    errSubscription?.cancel();
    super.dispose();
  }

  /// 启动游戏
  Future<void> launchGame() async {
    const white = "\u001b[37m";
    const red = "\u001b[31m";

    Future(() async => await widget.launchUtil.launchCommand
      ..printInfo());

    process = await Process.start(
      await widget.launchUtil.launchCommand,
      [],
      workingDirectory: widget.game.mainPath,
    );

    // 监听子进程的错误
    if (kDebugMode) {
      errSubscription = process!.stderr.transform(utf8.decoder).listen((data) {
        print('$red$data'); // 打印错误
      });
    }

    // 监听子进程
    subscription = process!.stdout.transform(utf8.decoder).listen((data) {
      if (data.contains("Sound engine started")) {
        completer.complete();
      }
      if (kDebugMode) print("$white$data");
    });
    return await completer.future;
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
                    future: widget.launchUtil.retrieveLibraries.toList,
                    title: const Text("检索资源"),
                    onDone: (snapshot, hasError) {
                      if (snapshot.data!.isNotEmpty) {
                        hasError = true;
                      }
                    },
                  ),
                  _Task(
                    future: () =>
                        widget.launchUtil.login(appConfig.selectedAccount!),
                    title: const Text("登录"),
                    onDone: (snapshot, hasError) {
                      if (snapshot.data == null) {
                        hasError = true;
                      }
                    },
                  ),
                  _Task(
                    future: launchGame,
                    title: const Text("启动"),
                  ),
                ],
              ),
            ),
            onlyConfirm: true,
            onConfirmed: () {
              if (!completer.isCompleted) {
                // 强制关闭
                process?.kill(ProcessSignal.sigkill);
              }
              dialogPop();
            },
            confirmText: FutureBuilder(
              future: completer.future,
              builder: (context, snapshot) {
                return StatefulBuilder(builder: (context, setState) {
                  switch (snapshot.connectionState) {
                    // 启动成功后倒计时自动关闭窗口
                    case ConnectionState.done:
                      timer = Timer.periodic(Durations.extralong4, (time) {
                        if (seconds > 0) {
                          setState(() => seconds--);
                          if (seconds == 0) {
                            // 关闭 Process 并关闭窗口
                            Future.delayed(Durations.extralong4, dialogPop);
                          }
                        }
                      });
                    default:
                  }
                  return Text("取消${timer != null ? ' ($seconds)' : ''}");
                });
              },
            ),
          );
  }
}

/// 顺序执行任务
class _SequenceTaskItems extends StatefulWidget {
  const _SequenceTaskItems({required this.tasks});

  final List<_Task> tasks;

  @override
  State<_SequenceTaskItems> createState() => _SequenceTaskItemsState();
}

class _SequenceTaskItemsState extends State<_SequenceTaskItems> {
  final listenables = <ValueNotifier<_TaskFutureFunction>>[];
  final futures = <_TaskFutureFunction>[];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.tasks.length; i++) {
      final currentTaskFuture = widget.tasks[i].future;
      final next = i + 1;
      final nextTask = widget.tasks.elementAtOrNull(next);
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(widget.tasks.length, (index) {
        final task = widget.tasks[index];
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
                  child: () {
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
                  }(),
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
