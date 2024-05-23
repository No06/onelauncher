import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:nil/nil.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:one_launcher/utils/auth/ms_device_code_oauth.dart';
import 'package:one_launcher/utils/auth/ms_oauth.dart';
import 'package:one_launcher/utils/form_validator.dart';
import 'package:one_launcher/widgets/dyn_mouse_scroll.dart';
import 'package:one_launcher/pages/base_page.dart';
import 'package:one_launcher/widgets/textfield.dart';
import 'package:one_launcher/widgets/widget_group.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

import '../../models/config/theme_config.dart';
import '../../models/account/microsoft_account.dart';
import '../../models/account/offline_account.dart';
import '../../models/account/account.dart';
import '/widgets/dialog.dart';
import '../../widgets/snackbar.dart';

part 'form.dart';
part 'account_item.dart';
part 'add_account_dialog.dart';

class AccountPage extends RoutePage {
  const AccountPage({super.key, super.pageName = "账号"});

  @override
  Widget body(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          MyDynMouseScroll(
            builder: (context, controller, physics) => SingleChildScrollView(
              controller: controller,
              physics: physics,
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Column(
                  children: () {
                    final results = <Widget>[];
                    for (var account in appConfig.accounts) {
                      results.add(
                        ValueListenableBuilder(
                          key: ObjectKey(account),
                          valueListenable: appConfig.selectedAccountNotifier,
                          builder: (_, selectedAccount, __) => _AccountItem(
                            account: account,
                            isSelected: appConfig.selectedAccount == account,
                            onTap: () => appConfig.selectedAccount = account,
                            onRemoved: (account) {
                              appConfig.accounts.remove(account);
                              try {
                                appConfig.selectedAccount =
                                    appConfig.accounts.first;
                              } on StateError {
                                appConfig.selectedAccount = null;
                              }
                              Get.showSnackbar(successSnackBar("删除成功"));
                            },
                          ),
                        ),
                      );
                    }
                    return results;
                  }(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: FloatingActionButton(
                // onPressed: () => showDialog(
                //   context: context,
                //   barrierDismissible: false,
                //   builder: (context) => _DeviceCodeLoginDialog(
                //     response: (accessToken) {
                //       dialogPop();
                //       if (accessToken != null) {

                //       }
                //     },
                //   ),
                // ),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => _AddAccountDialog(
                    onSubmit: (account) {
                      if (appConfig.accounts.add(account)) {
                        appConfig.selectedAccount ??= account;
                        dialogPop();
                        Get.showSnackbar(successSnackBar("添加成功！"));
                      } else {
                        Get.showSnackbar(errorSnackBar("已有重复账号"));
                      }
                    },
                  ),
                ),
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
