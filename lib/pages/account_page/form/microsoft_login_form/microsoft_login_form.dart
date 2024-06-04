import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/account/microsoft_account.dart';
import 'package:one_launcher/utils/auth/ms_oauth.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:one_launcher/widgets/snackbar.dart';

import 'device_code_login_dialog.dart';
import 'login_webview.dart';

class MicosoftLoginForm extends StatelessWidget {
  const MicosoftLoginForm({super.key, required this.onSubmit});

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

  Future<void> _onTapWebviewLogin(BuildContext context) => showDialog<String>(
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
            child: const LoginWebviewDialog(),
          ),
        ),
      ).then((code) {
        if (code != null) _webViewLoginSubmit(context, code);
      });

  Future<void> _onTapDeviceCodeLogin(BuildContext context) =>
      showDialog<MicrosoftOAuthResponse>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const DeviceCodeLoginDialog(),
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
    return showDialog<T>(
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
