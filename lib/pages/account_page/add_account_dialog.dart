part of 'account_page.dart';

class _SegmentedItem {
  const _SegmentedItem({required this.name, required this.icon});

  final String name;
  final Widget icon;
}

class _AddAccountDialog extends StatelessWidget {
  _AddAccountDialog({required this.onSubmit});

  final void Function(Account account) onSubmit;

  static const _accountTypes = {
    AccountType.offline:
        _SegmentedItem(name: "离线", icon: Icon(Icons.public_off)),
    AccountType.microsoft:
        _SegmentedItem(name: "微软", icon: Icon(Icons.grid_view)),
    AccountType.custom: _SegmentedItem(name: "自定义", icon: Icon(Icons.tune)),
  };

  final _selectedAccountType = Rx<AccountType>(AccountType.offline);
  final _formKey = GlobalKey<FormState>();
  final _isLoading = false.obs;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<GlobalKey<FormState>>('formKey', _formKey));
  }

  @override
  Widget build(BuildContext context) {
    late Account account;
    late Widget form;
    return DefaultDialog(
      title: const Text("添加用户"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => SegmentedButton<AccountType>(
                onSelectionChanged: (set) =>
                    _selectedAccountType.value = set.first,
                segments: List.generate(_accountTypes.length, (index) {
                  final key = _accountTypes.keys.elementAt(index);
                  final item = _accountTypes[key]!;
                  return ButtonSegment(
                    value: key,
                    label: Text(item.name),
                    icon: item.icon,
                  );
                }),
                selected: {_selectedAccountType.value},
              ),
            ),
            const SizedBox(height: 15),
            Form(
              key: _formKey,
              child: Obx(() {
                switch (_selectedAccountType.value) {
                  case AccountType.offline:
                    return form = _OfflineLoginForm();
                  case AccountType.microsoft:
                    return form = _MicosoftLoginForm();
                  // TODO: 自定义登录
                  case AccountType.custom:
                    null;
                }
                return nil;
              }),
            ),
          ],
        ),
      ),
      actions: [
        const DialogCancelButton(onPressed: dialogPop, cancelText: Text("取消")),
        Obx(
          () => DialogConfirmButton(
            onPressed: _isLoading.value
                ? null
                : () async {
                    _isLoading(true);
                    switch (_selectedAccountType.value) {
                      case AccountType.offline:
                        if (_formKey.currentState!.validate()) {
                          account = (form as _OfflineLoginForm).submit();
                          onSubmit(account);
                        }
                      case AccountType.microsoft:
                        String? oauthCode; // Microsoft OAuth Code
                        await showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius: kDefaultBorderRadius,
                            ),
                            contentPadding: EdgeInsets.zero,
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              // TODO: Webview对Linux、MacOS的支持
                              child: _LoginWebview(
                                onSuccess: (code) {
                                  oauthCode = code;
                                  dialogPop();
                                },
                              ),
                            ),
                          ),
                        );
                        if (oauthCode == null) return;
                        account = await (form as _MicosoftLoginForm)
                            .submit(oauthCode!);
                        onSubmit(account);
                      case AccountType.custom:
                        throw UnimplementedError();
                    }
                    _isLoading(false);
                  },
            confirmText: _isLoading.value
                ? Transform.scale(
                    scale: 0.8,
                    child: const CircularProgressIndicator(
                      strokeAlign: CircularProgressIndicator.strokeAlignInside,
                    ),
                  )
                : const Text("确定"),
          ),
        ),
      ],
    );
  }
}

class _LoginWebview extends StatefulWidget {
  const _LoginWebview({this.onSuccess});

  final void Function(String code)? onSuccess;

  @override
  State<_LoginWebview> createState() => _LoginWebviewState();
}

class _LoginWebviewState extends State<_LoginWebview> {
  final _controller = WebviewController();
  final _subscriptions = <StreamSubscription>[];

  static const _backgroundColor = Colors.transparent;

  // Minecraft微软登录OAuth链接
  static const _loginUrl = 'https://login.live.com/oauth20_authorize.srf?'
      'client_id=00000000402b5328'
      '&response_type=code'
      '&scope=service%3A%3Auser.auth.xboxlive.com%3A%3AMBI_SSL'
      '&redirect_uri=https%3A%2F%2Flogin.live.com%2Foauth20_desktop.srf';

  // 正则用于获取授权码
  static final _codeRegex = RegExp(r"(?<=code=)[^&]+");

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    _controller.clearCache();
    _controller.clearCookies();
    _controller.dispose();
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
        if (match != null && match.group(0) != null) {
          final code = match.group(0)!;
          if (widget.onSuccess != null) {
            widget.onSuccess!(code);
          }
          debugPrint("授权码: $code");
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
          child: Card(
            color: Colors.transparent,
            margin: EdgeInsets.zero,
            elevation: 0,
            clipBehavior: Clip.antiAliasWithSaveLayer,
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
        ),
      ],
    );
  }
}
