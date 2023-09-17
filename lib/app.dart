import 'package:one_launcher/models/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      home: HomePage(),
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
        background ?? const SizedBox(),
        Scaffold(
          backgroundColor: background == null ? null : Colors.transparent,
          appBar: appBar(context),
          body: SizedBox(
            child: Column(
              children: [
                Expanded(child: body ?? const SizedBox()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

PreferredSizeWidget appBar(BuildContext context) => PreferredSize(
      preferredSize: const Size.fromHeight(kWindowCaptionHeight),
      child: WindowCaption(
        brightness: Theme.of(context).brightness,
        title: const Text('OneLauncher'),
        backgroundColor: Colors.transparent,
      ),
    );
