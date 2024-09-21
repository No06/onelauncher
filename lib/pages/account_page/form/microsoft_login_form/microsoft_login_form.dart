import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/account/mc_access_token.dart';
import 'package:one_launcher/models/account/microsoft_account.dart';
import 'package:one_launcher/api/minecraft_services_api.dart';
import 'package:one_launcher/api/oauth/client/microsoft_device_oauth_client.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:one_launcher/api/oauth/client/microsoft_oauth_client.dart';
import 'package:one_launcher/api/oauth/client/minecraft_oauth_client.dart';
import 'package:one_launcher/api/oauth/client/xbox_oauth_client.dart';
import 'package:one_launcher/api/oauth/token/microsoft_device_oauth_token.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:one_launcher/widgets/snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

part 'login_webview_dialog.dart';
part 'device_code_login_dialog.dart';

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

  Future<void> _onTapWebviewLogin(BuildContext context) {
    submit(String code) async {
      debugPrintInfo(code, title: "Got OAuth code");

      final cancelToken = CancelToken();

      accountGenerator() async {
        final msToken = await MicrosoftOAuthClient(kMinecraftClientId)
            .requestTokenByCode(code, cancelToken: cancelToken);
        final xboxOAuthClient = XboxOAuthClient();
        final xblToken = await xboxOAuthClient.requestToken(msToken.accessToken,
            cancelToken: cancelToken);
        final xstsToken = await xboxOAuthClient.requestXstsToken(xblToken.token,
            cancelToken: cancelToken);
        final mcToken = await MinecraftOAuthClient()
            .requestToken(xstsToken, cancelToken: cancelToken);
        final profile = await MinecraftServicesApi(mcToken.accessToken)
            .requestProfile(cancelToken: cancelToken);
        return MicrosoftAccount(
          uuid: profile.id,
          displayName: profile.name,
          accessToken: mcToken.accessToken,
          refreshToken: msToken.refreshToken!,
          notAfter:
              MinecraftAccessToken.validityToExpiredTime(mcToken.expiresIn),
          skin: profile.skins.first,
          loginType: MicrosoftLoginType.oauth20,
        );
      }

      onCancel() => cancelToken.cancel();

      final account = await _generateAccount(
          context: context, generator: accountGenerator, onCancel: onCancel);
      if (account != null) onSubmit(account);
    }

    return showDialog<String>(
      context: context,
      builder: (context) => const _MicrosoftLoginWebviewDialog(),
    ).then((code) {
      if (code != null) {
        dialogPop();
        submit(code);
      }
    });
  }

  Future<void> _onTapDeviceCodeLogin(BuildContext context) async {
    submit(MicrosoftDeviceOAuthToken token) async {
      final cancelToken = CancelToken();

      accountGenerator() async {
        final xboxOAuthClient = XboxOAuthClient();
        final xblToken = await xboxOAuthClient
            .requestToken('d=${token.accessToken}', cancelToken: cancelToken);
        final xstsToken = await xboxOAuthClient.requestXstsToken(xblToken.token,
            cancelToken: cancelToken);
        final mcToken = await MinecraftOAuthClient()
            .requestToken(xstsToken, cancelToken: cancelToken);
        final profile =
            await MinecraftServicesApi(mcToken.accessToken).requestProfile();
        return MicrosoftAccount(
          uuid: profile.id,
          displayName: profile.name,
          accessToken: mcToken.accessToken,
          refreshToken: token.refreshToken!,
          notAfter:
              MinecraftAccessToken.validityToExpiredTime(mcToken.expiresIn),
          skin: profile.skins.first,
          loginType: MicrosoftLoginType.devicecode,
        );
      }

      onCancel() => cancelToken.cancel();

      final account = await _generateAccount(
          context: context, generator: accountGenerator, onCancel: onCancel);
      if (account != null) onSubmit(account);
    }

    return showDialog<MicrosoftDeviceOAuthToken>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _DeviceCodeLoginDialog(),
    ).then((token) {
      if (token != null) {
        dialogPop();
        submit(token);
      }
    });
  }

  Future<T?> _generateAccount<T>({
    required BuildContext context,
    required FutureOr<T> Function() generator,
    required VoidCallback onCancel,
  }) async {
    onCancel = () {
      dialogPop();
      onCancel();
    };

    showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
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
          actions: [DialogCancelButton(onPressed: onCancel)],
        );
      },
    );

    T? account;
    try {
      account = await generator();
    } on DioException catch (e) {
      debugPrintError(e.message.toString());
      showSnackbar(errorSnackBar(title: "网络请求错误", content: e.message));
    } finally {
      dialogPop();
    }

    return account;
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
    final shape = this.shape ??
        const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)));
    return Card(
      color: cardColor,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
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
