import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

class LoginWebviewDialog extends StatefulWidget {
  const LoginWebviewDialog({super.key});

  @override
  State<LoginWebviewDialog> createState() => _LoginWebviewDialogState();
}

class _LoginWebviewDialogState extends State<LoginWebviewDialog> {
  final _controller = WebviewController();
  final _subscriptions = <StreamSubscription>[];

  final _backgroundColor = Colors.transparent;

  // Minecraft微软登录OAuth链接
  final _loginUrl = 'https://login.live.com/oauth20_authorize.srf?'
      'client_id=00000000402b5328'
      '&response_type=code'
      '&scope=service%3A%3Auser.auth.xboxlive.com%3A%3AMBI_SSL'
      '&redirect_uri=https%3A%2F%2Flogin.live.com%2Foauth20_desktop.srf';

  // 正则用于获取授权码
  final _codeRegex = RegExp(r"(?<=code=)[^&]+");

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    Future.wait([
      for (var s in _subscriptions) s.cancel(),
      _controller.clearCache(),
      _controller.clearCookies(),
    ]).then((value) => _controller.dispose());
    super.dispose();
  }

  Future<void> initPlatformState() async {
    try {
      await _controller.initialize();

      _subscriptions
          .add(_controller.containsFullScreenElementChanged.listen((flag) {
        debugPrint('Contains fullscreen element: $flag');
        windowManager.setFullScreen(flag);
      }));

      await _controller.setBackgroundColor(_backgroundColor);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl(_loginUrl.toString());

      _controller.url.listen((url) async {
        final match = _codeRegex.firstMatch(url);
        final code = match?.group(0);
        if (match != null && code != null) {
          debugPrint("授权码: $code");
          dialogPop(result: code);
        } else {
          debugPrint("未找到授权码");
        }
      });

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Code: ${e.code}'),
                  Text('Message: ${e.message}'),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Continue'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(2),
          child: IntrinsicHeight(
            child: Row(children: [
              StreamBuilder(
                stream: _controller.historyChanged,
                builder: (context, snapshot) => IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: snapshot.data?.canGoBack ?? false
                      ? _controller.goBack
                      : null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _controller.reload,
              ),
              const Expanded(
                child: DragToMoveArea(
                  child: SizedBox.expand(),
                ),
              ),
              const IconButton(
                icon: Icon(Icons.close),
                onPressed: dialogPop,
              ),
            ]),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Webview(_controller),
              StreamBuilder<LoadingState>(
                stream: _controller.loadingState,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data == LoadingState.loading) {
                    return const LinearProgressIndicator();
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
