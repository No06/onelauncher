import 'package:flutter/material.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/pages/simple_app_page.dart';
import 'package:one_launcher/widgets/dialog.dart';

class GameStartupPage extends StatelessWidget {
  const GameStartupPage({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    var startupFinished = false;
    return SimpleMaterialAppPage(
      leadOnPressed: () {
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
      title: Text(game.version.id),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder(
                  future: game.retrieveNonExitedLibraries.toList(),
                  builder: (context, snapshot) {
                    final state = snapshot.connectionState;
                    if (state == ConnectionState.done) {
                      for (var i in snapshot.data!) {
                        print(i.name);
                      }
                    }
                    return _StepTask(
                      name: "检索游戏资源",
                      isWatting: state == ConnectionState.waiting,
                      hasError: snapshot.hasError ||
                          state == ConnectionState.done &&
                              snapshot.data!.isNotEmpty,
                      isDone: state == ConnectionState.done,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTask extends StatelessWidget {
  const _StepTask({
    this.isWatting = true,
    this.hasError = false,
    this.isDone = false,
    required this.name,
    this.child,
  });

  final bool isWatting;
  final bool hasError;
  final bool isDone;
  final String name;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(iconTheme: const IconThemeData(size: 32)),
      child: DefaultTextStyle(
        style: theme.textTheme.titleLarge!,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWatting)
                  const CircularProgressIndicator()
                else if (hasError)
                  const Icon(Icons.error)
                else if (isDone)
                  const Icon(Icons.done),
                const SizedBox(width: 8),
                Text(name),
              ],
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
