import 'package:flutter/material.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/widgets/dialog.dart';

class GameStartupDialog extends StatelessWidget {
  const GameStartupDialog({super.key, required this.game});

  final Game game;

  final errorIconColor = Colors.red;
  final doneIconColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: const Text("为启动游戏做准备"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: game.retrieveLibraries.toList(),
              builder: (context, snapshot) {
                final state = snapshot.connectionState;
                return Row(
                  children: [
                    if (state == ConnectionState.none)
                      const Icon(Icons.hourglass_empty_rounded)
                    else if (state == ConnectionState.waiting)
                      const CircularProgressIndicator()
                    else if (state == ConnectionState.done &&
                        snapshot.data!.isNotEmpty)
                      Icon(Icons.error, color: errorIconColor)
                    else
                      Icon(Icons.done, color: doneIconColor),
                    const SizedBox(width: 8),
                    const Text("检索游戏资源"),
                  ],
                );
              },
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
