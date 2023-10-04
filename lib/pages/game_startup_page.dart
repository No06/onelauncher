import 'package:flutter/material.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';
import 'package:one_launcher/widgets/dialog.dart';

class GameStartupPage extends StatelessWidget {
  const GameStartupPage({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    var startupFinished = false;
    return AppPage(
      body: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(game.version.id),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            padding: const EdgeInsets.all(16),
            onPressed: () {
              if (startupFinished) {
                Navigator.pop(context);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => WarningDialog(
                    content: const Text("启动还未完成，你确定要强制退出吗？"),
                    onConfirmed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                );
              }
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepTask(
                    stream: game.retrieveNonExitedLibraries,
                    name: "检索游戏资源",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepTask<T> extends StatelessWidget {
  const _StepTask({
    this.isWatting,
    this.hasError,
    this.isDone,
    required this.name,
    this.stream,
  });

  final VoidCallback? isWatting;
  final VoidCallback? hasError;
  final VoidCallback? isDone;
  final String name;
  final Stream<T>? stream;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder(
          stream: stream,
          builder: (_, snapshot) {
            if (snapshot.hasError) {
              return const Icon(Icons.error);
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return const Row(
                children: [Icon(Icons.done)],
              );
            }
            return const CircularProgressIndicator();
          },
        ),
        Text(name),
      ],
    );
  }
}

enum StepState {
  waitting,
  running,
  finished;
}
