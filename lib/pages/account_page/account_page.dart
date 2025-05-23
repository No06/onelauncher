import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mdi_icons/flutter_mdi_icons.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/microsoft_account.dart';
import 'package:one_launcher/models/account/offline_account.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/pages/account_page/form/microsoft_login_form/microsoft_login_form.dart';
import 'package:one_launcher/pages/common/base_page.dart';
import 'package:one_launcher/provider/account_provider.dart';
import 'package:one_launcher/utils/extension/color_extension.dart';
import 'package:one_launcher/utils/form_validator.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:one_launcher/widgets/dyn_mouse_scroll.dart';
import 'package:one_launcher/widgets/snackbar.dart';
import 'package:one_launcher/widgets/textfield.dart';
import 'package:one_launcher/widgets/widget_group.dart';
import 'package:uuid/uuid.dart';

part './form/custom_login_form.dart';
part './form/offline_login_form.dart';
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
              child: Consumer(
                builder: (context, ref, child) {
                  final accounts = ref.watch(accountProvider).accounts;
                  return Column(
                    children: List.generate(accounts.length, (i) {
                      final account = accounts.elementAt(i);
                      return _AccountItem(
                        key: ObjectKey(account),
                        account: account,
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Consumer(
                builder: (context, ref, child) {
                  return FloatingActionButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => _AddAccountDialog(
                        onSubmit: (account) {
                          if (ref
                              .read(accountProvider.notifier)
                              .addAccount(account)) {
                            showSnackbar(successSnackBar(title: "添加成功！"));
                          } else {
                            showSnackbar(errorSnackBar(title: "已有重复账号"));
                          }
                        },
                      ),
                    ),
                    child: child,
                  );
                },
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
