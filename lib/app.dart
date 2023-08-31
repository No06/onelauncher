import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beacon/controller/storage.dart';
import 'package:window_manager/window_manager.dart';

import 'interface/window_surface.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final configController = Get.find<ConfigController>();
    return configController.obx(
      (data) {
        final theme = configController.appTheme;
        return GetMaterialApp(
          theme: theme.lightTheme(),
          darkTheme: theme.darkTheme(),
          themeMode: theme.mode,
          debugShowCheckedModeBanner: false,
          home: const Home(),
        );
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kWindowCaptionHeight),
        child: WindowCaption(
          brightness: Theme.of(context).brightness,
          title: const Text('Beacon'),
          backgroundColor: Colors.transparent,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: const Column(
          children: [
            Divider(height: 1),
            Expanded(child: WindowSurface()),
          ],
        ),
      ),
    );
  }
}
