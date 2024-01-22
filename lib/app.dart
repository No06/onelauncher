import 'dart:io';

import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_launcher/widgets/window_caption/window_caption.dart';
import 'package:one_launcher/widgets/window_caption/button.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppConfig.instance.theme;
    return GetMaterialApp(
      theme: theme.lightTheme(),
      darkTheme: theme.darkTheme(),
      themeMode: theme.mode,
      debugShowCheckedModeBanner: false,
      home: DragToResizeArea(child: HomePage()),
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({super.key, this.body, this.background});

  final Widget? body;
  final Widget? background;

  PreferredSize appBar(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return PreferredSize(
      preferredSize: const Size.fromHeight(kWindowCaptionHeight),
      child: MyWindowCaption(
        brightness: Theme.of(context).brightness,
        title: const Text(appName),
        backgroundColor: Colors.transparent,
        icons: [
          MyWindowCaptionButton.minimize(
            animated: true,
            brightness: brightness,
            onPressed: () async {
              bool isMinimized = await windowManager.isMinimized();
              if (isMinimized) {
                windowManager.restore();
              } else {
                windowManager.minimize();
              }
            },
          ),
          _WindowCaptionMaximizeButton(brightness: brightness),
          MyWindowCaptionButton.close(
            animated: true,
            brightness: brightness,
            onPressed: windowManager.close,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (background != null) background!,
        Scaffold(
          backgroundColor: background == null ? null : Colors.transparent,
          // TODO: 为 Linux 或 MacOS 定制窗口栏
          appBar: Platform.isWindows ? appBar(context) : null,
          body: body,
        ),
      ],
    );
  }
}

class _WindowCaptionMaximizeButton extends StatefulWidget {
  const _WindowCaptionMaximizeButton({this.brightness = Brightness.light});

  final Brightness brightness;

  @override
  State<_WindowCaptionMaximizeButton> createState() =>
      _WindowCaptionMaximizeButtonState();
}

class _WindowCaptionMaximizeButtonState
    extends State<_WindowCaptionMaximizeButton> with WindowListener {
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
    return FutureBuilder<bool>(
      future: windowManager.isMaximized(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data == true) {
          return MyWindowCaptionButton.unmaximize(
            animated: true,
            brightness: widget.brightness,
            onPressed: windowManager.unmaximize,
          );
        }
        return MyWindowCaptionButton.maximize(
          animated: true,
          brightness: widget.brightness,
          onPressed: windowManager.maximize,
        );
      },
    );
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }
}
