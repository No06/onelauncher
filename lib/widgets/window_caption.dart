import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:one_launcher/consts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_titlebar/windows_titlebar.dart';

class MyWindowCaption extends HookConsumerWidget {
  const MyWindowCaption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final isMaximized = useValueNotifier<bool?>(null);

    final windowButtonColor = () {
      switch (brightness) {
        case Brightness.dark:
          return const WindowButtonColor.dark();
        case Brightness.light:
          return const WindowButtonColor.light();
      }
    }();
    final closeWindowButtonColor = () {
      switch (brightness) {
        case Brightness.dark:
          return const WindowButtonColor.closeDark();
        case Brightness.light:
          return const WindowButtonColor.closeLight();
      }
    }();

    return WindowTitleBar(
      title: const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(appName),
        ),
      ),
      actions: [
        WindowButton.minimize(
          animated: true,
          buttonColor: windowButtonColor,
          onTap: () async {
            bool isMinimized = await windowManager.isMinimized();
            if (isMinimized) {
              windowManager.restore();
            } else {
              windowManager.minimize();
            }
          },
        ),
        FutureBuilder(
          future: windowManager.isMaximized(),
          builder: (context, snapshot) => ValueListenableBuilder(
            valueListenable: isMaximized,
            builder: (context, isMaximized, child) {
              isMaximized = isMaximized ??= snapshot.hasData && snapshot.data!;
              if (isMaximized) {
                return WindowButton.unmaximize(
                  buttonColor: windowButtonColor,
                  onTap: windowManager.unmaximize,
                );
              }
              return WindowButton.maximize(
                buttonColor: windowButtonColor,
                onTap: windowManager.maximize,
              );
            },
          ),
        ),
        WindowButton.close(
          animated: true,
          buttonColor: closeWindowButtonColor,
          onTap: windowManager.close,
        ),
      ],
    );
  }
}
