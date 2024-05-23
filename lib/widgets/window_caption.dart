import 'package:flutter/material.dart';
import 'package:one_launcher/consts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_titlebar/windows_titlebar.dart';

class MyWindowCaption extends StatelessWidget {
  const MyWindowCaption({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return WindowTitleBar(
      title: const Text(appName),
      actions: [
        WindowButton.minimize(
          animated: true,
          brightness: brightness,
          onTap: () async {
            bool isMinimized = await windowManager.isMinimized();
            if (isMinimized) {
              windowManager.restore();
            } else {
              windowManager.minimize();
            }
          },
        ),
        _MaximizeButton(brightness: brightness),
        WindowButton.close(
          animated: true,
          brightness: brightness,
          onTap: windowManager.close,
        ),
      ],
    );
  }
}

class _MaximizeButton extends StatefulWidget {
  const _MaximizeButton({required this.brightness});

  final Brightness brightness;

  @override
  State<_MaximizeButton> createState() => _MaximizeButtonState();
}

class _MaximizeButtonState extends State<_MaximizeButton> with WindowListener {
  bool? isMaximize;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unmaximizeButton = WindowButton.unmaximize(
      animated: true,
      brightness: Theme.of(context).brightness,
      onTap: windowManager.unmaximize,
    );

    final maximizeButton = WindowButton.maximize(
      animated: true,
      brightness: Theme.of(context).brightness,
      onTap: windowManager.maximize,
    );
    if (isMaximize == null) {
      return FutureBuilder(
        future: windowManager.isMaximized(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return unmaximizeButton;
          }
          return maximizeButton;
        },
      );
    }

    if (isMaximize!) {
      return unmaximizeButton;
    }

    return maximizeButton;
  }

  @override
  void onWindowMaximize() async {
    setState(() => isMaximize = true);
  }

  @override
  void onWindowUnmaximize() {
    setState(() => isMaximize = false);
  }
}
