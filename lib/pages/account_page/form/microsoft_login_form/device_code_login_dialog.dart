part of 'microsoft_login_form.dart';

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
      if (resp != null) dialogPop(result: resp);
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
