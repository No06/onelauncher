import 'package:flutter/material.dart';
import 'package:one_launcher/consts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_titlebar/windows_titlebar.dart';

class MyWindowCaption extends StatelessWidget {
  const MyWindowCaption({super.key});

  void toggleMinimize() async => await windowManager.isMinimized()
      ? windowManager.restore()
      : windowManager.minimize();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final windowButtonColor = switch (brightness) {
      Brightness.dark => const WindowButtonColor.dark(),
      Brightness.light => const WindowButtonColor.light(),
    };
    final closeWindowButtonColor = switch (brightness) {
      Brightness.dark => const WindowButtonColor.closeDark(),
      Brightness.light => const WindowButtonColor.closeLight(),
    };

    return WindowTitleBar(
      title: const DragToMoveArea(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(kAppName),
          ),
        ),
      ),
      actions: [
        WindowButton.minimize(
          animated: true,
          buttonColor: windowButtonColor,
          onTap: toggleMinimize,
        ),
        _WindowMaximizeToggleButton(
          animated: true,
          color: windowButtonColor,
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

class _WindowMaximizeToggleButton extends StatefulWidget {
  const _WindowMaximizeToggleButton({required this.color, this.animated});

  final WindowButtonColor color;
  final bool? animated;

  @override
  State<_WindowMaximizeToggleButton> createState() =>
      _WindowMaximizeToggleButtonState();
}

class _WindowMaximizeToggleButtonState
    extends State<_WindowMaximizeToggleButton> with WindowListener {
  var isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((isMaximized) => setState(() {
          this.isMaximized = isMaximized;
        }));
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() {
        isMaximized = true;
      });

  @override
  void onWindowUnmaximize() => setState(() {
        isMaximized = false;
      });

  @override
  Widget build(BuildContext context) {
    return isMaximized
        ? WindowButton.unmaximize(
            animated: widget.animated,
            buttonColor: widget.color,
            onTap: windowManager.unmaximize,
          )
        : WindowButton.maximize(
            animated: widget.animated,
            buttonColor: widget.color,
            onTap: windowManager.maximize,
          );
  }
}
