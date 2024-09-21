part of 'microsoft_login_form.dart';

class _MicrosoftLoginWebviewDialog extends StatelessWidget {
  const _MicrosoftLoginWebviewDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: kDefaultBorderRadius,
      ),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        // TODO: Webview对Linux、MacOS的支持
        child: const _MicrosoftLoginWebviewScreen(),
      ),
    );
  }
}

class _MicrosoftLoginWebviewScreen extends StatefulWidget {
  const _MicrosoftLoginWebviewScreen();

  @override
  State<_MicrosoftLoginWebviewScreen> createState() =>
      _MicrosoftLoginWebviewScreenState();
}

class _MicrosoftLoginWebviewScreenState
    extends State<_MicrosoftLoginWebviewScreen> {
  final _controller = WebviewController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    Future.wait([
      _controller.clearCache(),
      _controller.clearCookies(),
    ]).then((value) => _controller.dispose());
    super.dispose();
  }

  Future<void> initPlatformState() async {
    // Minecraft微软登录OAuth链接
    const loginUrl = 'https://login.live.com/oauth20_authorize.srf?'
        'client_id=$kMinecraftClientId'
        '&response_type=code'
        '&scope=${MicrosoftOAuthClient.scope}'
        '&redirect_uri=${MicrosoftOAuthClient.redirectUri}'; // 正则用于获取授权码
    final codeRegex = RegExp(r"(?<=code=)[^&]+");

    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl(loginUrl);

      _controller.url.listen((url) async {
        final match = codeRegex.firstMatch(url);
        final code = match?.group(0);
        final hasCode = match != null && code != null;

        if (hasCode) dialogPop(result: code);
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
                  onPressed: Navigator.of(context).pop,
                  child: const Text('Continue'),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(2),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const Flexible(
                  child: DragToMoveArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                const IconButton(
                  icon: Icon(Icons.close),
                  onPressed: dialogPop,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: !_controller.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Stack(
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
