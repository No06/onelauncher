import 'dart:io';

import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_titlebar/windows_titlebar.dart';

import 'pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppConfig.instance.theme;
    return GetMaterialApp(
      builder: (context, widget) {
        Widget errorWidget(FlutterErrorDetails errorDetails) => Scaffold(
              body: Center(
                child: Text('遇到了预料之外的错误：${errorDetails.library}'),
              ),
            );
        ErrorWidget.builder = (errorDetails) => errorWidget(errorDetails);
        if (widget != null) return widget;
        throw StateError('widget is null');
      },
      theme: theme.lightTheme(),
      darkTheme: theme.darkTheme(),
      themeMode: theme.mode,
      debugShowCheckedModeBanner: false,
      home: const DragToResizeArea(child: HomePage()),
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({super.key, this.body, this.background});

  final Widget? body;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (background != null) background!,
        Scaffold(
          backgroundColor: background == null ? null : Colors.transparent,
          // TODO: 为 Linux 或 MacOS 定制窗口栏
          appBar: Platform.isWindows
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(kWindowCaptionHeight),
                  child: _AppBar(),
                )
              : null,
          body: body,
        ),
      ],
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

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
  const _MaximizeButton({this.brightness = Brightness.light});

  final Brightness brightness;

  @override
  State<_MaximizeButton> createState() => _MaximizeButtonState();
}

class _MaximizeButtonState extends State<_MaximizeButton> with WindowListener {
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
          return WindowButton.unmaximize(
            animated: true,
            brightness: widget.brightness,
            onTap: windowManager.unmaximize,
          );
        }
        return WindowButton.maximize(
          animated: true,
          brightness: widget.brightness,
          onTap: windowManager.maximize,
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
