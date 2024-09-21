part of 'microsoft_login_form.dart';

final _initiateAuthenticationProvider = FutureProvider.autoDispose((ref) {
  final client = MicrosoftDeviceOAuthClient();
  return client.requestDeviceAuthorization();
});

class _DeviceCodeLoginDialog extends ConsumerStatefulWidget {
  const _DeviceCodeLoginDialog();

  @override
  ConsumerState<_DeviceCodeLoginDialog> createState() =>
      _DeviceCodeLoginDialogState();
}

class _DeviceCodeLoginDialogState
    extends ConsumerState<_DeviceCodeLoginDialog> {
  var visible = false;
  final authenticationCompleter = Completer<MicrosoftDeviceOAuthToken>();
  final client = MicrosoftDeviceOAuthClient();
  late final Stream<MicrosoftDeviceOAuthToken> stream;

  MicrosoftDeviceAuthorizationResponse? get authorizationData =>
      ref.read(_initiateAuthenticationProvider).value;

  Future<void> _onTapToLogin() async {
    await Clipboard.setData(ClipboardData(text: authorizationData!.userCode));

    final uri = Uri.parse(authorizationData!.verificationUri);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showSnackbar(errorSnackBar(title: '跳转链接失败'));
    }
  }

  Future<void> _initiateAuthentication() async {
    await ref.read(_initiateAuthenticationProvider.future);
    final token = await pollingRequestUserAuthentication();
    if (token == null) return;
    if (mounted) Navigator.of(context).pop(token);
  }

  Future<MicrosoftDeviceOAuthToken?> pollingRequestUserAuthentication() async {
    final data = ref.read(_initiateAuthenticationProvider).value!;

    /// Timer
    var seconds = 0;
    increase(Timer timer) => seconds += 1;
    final timer = Timer.periodic(const Duration(seconds: 1), increase);

    MicrosoftDeviceOAuthToken? token;
    while (seconds < data.expiresIn && mounted) {
      try {
        token = await client.requestUserAuthentication(data.deviceCode);
        break;
      } on MicrosoftDeviceOAuthException catch (e) {
        switch (e.type) {
          case MicrosoftDeviceOAuthExceptionType.authorizationPending:
            continue;
          case MicrosoftDeviceOAuthExceptionType.authorizationDeclined:
            showSnackbar(warningSnackBar(title: "最终用户拒绝了授权请求"));
          case MicrosoftDeviceOAuthExceptionType.badVerificationCode:
            showSnackbar(errorSnackBar(
              title: "这可能是个Bug",
              content: '发送到 /token 端点的 device_code 无法识别',
            ));
          case MicrosoftDeviceOAuthExceptionType.expiredToken:
            showSnackbar(errorSnackBar(title: '请求超时'));
          case MicrosoftDeviceOAuthExceptionType.unknown:
            // TODO: 补充错误详细说明
            showSnackbar(errorSnackBar(title: '啊哦，发生了意料之外的问题'));
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
        break;
      } finally {
        await Future.delayed(Duration(seconds: data.interval));
      }
    }

    timer.cancel();
    return token;
  }

  @override
  void initState() {
    super.initState();
    _initiateAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final activity = ref.watch(_initiateAuthenticationProvider);
    final isAlready = activity.hasValue;

    return DefaultDialog(
      onCanceled: dialogPop,
      confirmText: const Text('复制并前往验证'),
      onConfirmed: isAlready ? _onTapToLogin : null,
      content: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  switch (activity) {
                    AsyncData() => Text(
                        "授权码",
                        style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600, letterSpacing: 3),
                      ),
                    AsyncError() => const SizedBox(),
                    _ => Text("请求中...", style: textTheme.headlineSmall),
                  },
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: switch (activity) {
                      AsyncData(:final value) => _CodeViewer(value.userCode),
                      AsyncError() => const Text('啊哦，发生预料之外的错误。'),
                      _ => const CircularProgressIndicator(),
                    },
                  ),
                  switch (activity) {
                    AsyncData(:final value) =>
                      Text(value.message, style: textTheme.bodyLarge),
                    _ => const SizedBox(),
                  }
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeViewer extends StatelessWidget {
  const _CodeViewer(this.code);

  final String code;

  void onTapCopy() => Clipboard.setData(ClipboardData(text: code));

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: "点击复制",
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: kDefaultBorderRadius,
        ),
        color: colors.secondaryContainer,
        elevation: 3,
        child: InkWell(
          onTap: onTapCopy,
          borderRadius: kDefaultBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              code,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 8,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
