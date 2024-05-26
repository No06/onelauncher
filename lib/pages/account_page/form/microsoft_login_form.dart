part of '../account_page.dart';

class _MicosoftLoginForm extends StatelessWidget {
  const _MicosoftLoginForm({required this.onSubmit});

  final void Function(MicrosoftAccount account) onSubmit;
  final _iconSize = 36.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = colors.primary;
    final primaryTextColor = colors.onPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _SelectionItem(
          onTap: () => _onTapWebviewLogin(context),
          cardColor: primaryColor,
          icon: Icon(Icons.public, size: _iconSize, color: primaryTextColor),
          text: Text("Webview 登录", style: TextStyle(color: primaryTextColor)),
        ),
        _SelectionItem(
          onTap: () => _onTapDeviceCodeLogin(context),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            side: BorderSide(color: primaryColor, width: 1.5),
          ),
          icon: Icon(Icons.computer, size: _iconSize),
          text: const Text("设备授权码登录"),
        ),
      ],
    );
  }

  void _onTapWebviewLogin(BuildContext context) => showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: kDefaultBorderRadius,
          ),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            // TODO: Webview对Linux、MacOS的支持
            child: const _LoginWebview(),
          ),
        ),
      ).then((code) {
        if (code != null) _webViewLoginSubmit(context, code);
      });

  void _onTapDeviceCodeLogin(BuildContext context) =>
      showDialog<MicrosoftOAuthResponse>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _DeviceCodeLoginDialog(),
      ).then((response) {
        if (response != null) _deviceCodeLoginSubmit(context, response);
      });

  Future<void> _webViewLoginSubmit(BuildContext context, String code) async {
    final account = await _generateAccount(
      context: context,
      function: () => MicrosoftAccount.generateByOAuthCode(code),
    );
    if (account != null) onSubmit(account);
  }

  Future<void> _deviceCodeLoginSubmit(
    BuildContext context,
    MicrosoftOAuthResponse response,
  ) async {
    final account = await _generateAccount(
      context: context,
      function: () => MicrosoftAccount.generateByMsToken(
        msAccessToken: "d=${response.accessToken}",
        refreshToken: response.refreshToken,
      ),
    );
    if (account != null) onSubmit(account);
  }

  Future<T?> _generateAccount<T>({
    required BuildContext context,
    required Future<T> Function() function,
  }) {
    return showDialog<T?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FutureBuilder(
        future: function(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            dialogPop(result: snapshot.data);
            if (snapshot.hasError) {
              showSnackbar(errorSnackBar("请求错误：${snapshot.error.toString()}"));
            }
          }
          return DefaultDialog(
            title: const Text("登录成功"),
            content: Row(
              children: [
                const Text("正在获取游戏授权码"),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Transform.scale(
                    scale: 0.8,
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
            actions: const [DialogCancelButton(onPressed: dialogPop)],
          );
        },
      ),
    );
  }
}

class _SelectionItem extends StatelessWidget {
  const _SelectionItem({
    this.cardColor,
    required this.icon,
    required this.text,
    required this.onTap,
    this.shape,
  });

  final Color? cardColor;
  final Widget icon;
  final Widget text;
  final void Function()? onTap;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: cardColor,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [icon, text],
          ),
        ),
      ),
    );
  }
}

class _LoginWebview extends StatefulWidget {
  const _LoginWebview();

  @override
  State<_LoginWebview> createState() => _LoginWebviewState();
}

class _LoginWebviewState extends State<_LoginWebview> {
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

class _DeviceCodeLoginDialog extends StatefulWidget {
  const _DeviceCodeLoginDialog();

  @override
  State<_DeviceCodeLoginDialog> createState() => _DeviceCodeLoginDialogState();
}

class _DeviceCodeLoginDialogState extends State<_DeviceCodeLoginDialog> {
  var visible = false;
  String? _deviceCode;
  String? _verificationUrl;
  final completer = Completer<MicrosoftOAuthResponse?>(); // 返回 accessToken
  final util = MicrosoftDeviceCodeOAuth();

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showSnackbar(errorSnackBar('跳转链接失败 $url'));
    }
  }

  Future<void> _clip() => Clipboard.setData(ClipboardData(text: _deviceCode!));

  @override
  void initState() {
    super.initState();
    // 轮询
    util
        .getAccessTokenByUserCode(
      startPolling: (deviceCode, verificationUrl) => setState(() {
        _deviceCode = deviceCode;
        _verificationUrl = verificationUrl;
      }),
    )
        .then((resp) {
      completer.complete(resp);
      dialogPop(result: resp);
    });
  }

  @override
  void dispose() {
    util.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    return DefaultDialog(
      onCanceled: dialogPop,
      confirmText: const Text('前往登录'),
      onConfirmed: _verificationUrl == null
          ? null
          : () async {
              await _clip();
              await _launchURL(_verificationUrl!);
            },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("授权码", style: textTheme.headlineSmall),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FutureBuilder(
                  future: completer.future,
                  builder: (context, snapshot) {
                    if (_deviceCode != null && _verificationUrl != null) {
                      return Tooltip(
                        message: "点击复制",
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          color: colors.secondaryContainer,
                          elevation: 3,
                          child: InkWell(
                            onTap: _clip,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child:
                                  StatefulBuilder(builder: (context, setState) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      visible
                                          ? _deviceCode!
                                          : _deviceCode!
                                              .replaceAll(RegExp(r'.'), '∗'),
                                      style: textTheme.titleLarge?.copyWith(
                                        letterSpacing: 8,
                                        color: colors.onSecondaryContainer,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          setState(() => visible = !visible),
                                      icon: visible
                                          ? const Icon(Icons.visibility)
                                          : const Icon(Icons.visibility_off),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.error),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
          Text(
            "点击登录后，自动复制授权码，跳出认证页面直接粘贴",
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
