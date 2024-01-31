import 'package:nil/nil.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:one_launcher/utils/auth/account_info_util.dart';
import 'package:one_launcher/utils/auth/ms_auth_util.dart';
import 'package:one_launcher/utils/form_validator.dart';
import 'package:one_launcher/widgets/route_page.dart';
import 'package:one_launcher/widgets/widget_group.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../models/config/theme_config.dart';
import '../../models/account/microsoft_account.dart';
import '../../models/account/offline_account.dart';
import '../../models/account/account.dart';
import '/widgets/dialog.dart';
import '../../widgets/snackbar.dart';

part 'form.dart';

class AccountPage extends RoutePage {
  const AccountPage({super.key, required super.pageName});

  @override
  Widget body(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          DynMouseScroll(
            animationCurve: kMouseScrollAnimationCurve,
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
                onPressed: () => showDialog(
                  context: Get.context!,
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

// FIXME: 加载卡顿
class _AccountItem extends StatelessWidget {
  _AccountItem({
    required this.account,
    this.isSelected = false,
    this.onTap,
    this.onRemoved,
  });

  final Account account;
  final bool isSelected;
  final void Function()? onTap;
  final void Function(Account account)? onRemoved;

  final isTapDown = RxBool(false);
  final isHover = RxBool(false);

  Color getColor({
    required Color selectedColor,
    required Color unSelectedColor,
    required Brightness brightness,
  }) {
    if (isSelected) {
      return selectedColor;
    }
    if (isTapDown.value) {
      return selectedColor.withOpacity(.7);
    }
    if (isHover.value) {
      return dynamicColorWithValue(unSelectedColor, -0.1, 0.1, brightness);
    }
    return unSelectedColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedColor = colors.primary;
    final unSelectedColor = colorWithValue(colors.surface, .1);
    final fontColor = isSelected ? colors.onPrimary : colors.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 58,
        child: GestureDetector(
          onTap: onTap,
          onTapDown: (details) => isTapDown(true),
          onTapCancel: () => isTapDown(false),
          onTapUp: (details) => isTapDown(false),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) => isHover(true),
            onExit: (event) => isHover(false),
            child: Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: isTapDown.value
                    ? const EdgeInsets.symmetric(vertical: 1, horizontal: 5)
                    : EdgeInsets.zero,
                child: Material(
                  elevation: isTapDown.value ? 0 : 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: kDefaultBorderRadius),
                  clipBehavior: Clip.antiAlias,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    color: getColor(
                      selectedColor: selectedColor,
                      unSelectedColor: unSelectedColor,
                      brightness: theme.brightness,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Wrap(
                            spacing: 15,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(1),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black38,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    HookBuilder(
                                      builder: (_) {
                                        final future = useMemoized(() async =>
                                            (await account.getSkin())
                                                .drawAvatar());
                                        final snapshot = useFuture(future);
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (snapshot.hasError) {
                                            return const Icon(Icons.error);
                                          } else {
                                            return Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.contain,
                                            );
                                          }
                                        } else {
                                          return CircularProgressIndicator(
                                            color: isSelected
                                                ? colors.onPrimary
                                                : null,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.displayName,
                                    style: TextStyle(
                                      color: fontColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    account is OfflineAccount
                                        ? "离线账号"
                                        : account is MicrosoftAccount
                                            ? "微软账号"
                                            : "未知账号",
                                    style: TextStyle(color: fontColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Wrap(
                            spacing: 5,
                            children: [
                              if (account is MicrosoftAccount)
                                IconButton(
                                  onPressed: () {
                                    (account as MicrosoftAccount)
                                        .refreshProfile();
                                  },
                                  icon: Icon(
                                    Icons.refresh,
                                    color: fontColor,
                                  ),
                                ),
                              ObxValue(
                                (p0) => AbsorbPointer(
                                  absorbing: p0.value,
                                  child: IconButton(
                                    onPressed: () => p0.value = !p0.value,
                                    icon: Icon(Icons.checkroom_rounded,
                                        color: fontColor),
                                  ),
                                ),
                                false.obs,
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: fontColor),
                                onPressed: () {
                                  showDialog(
                                    context: Get.context!,
                                    builder: (context) => WarningDialog(
                                      title: const Text("删除用户"),
                                      content: const Text("你确定要删除这条数据吗？"),
                                      onConfirmed: () {
                                        (onRemoved ?? () {})(account);
                                        dialogPop();
                                      },
                                      onCanceled: dialogPop,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddAccountDialog extends StatelessWidget {
  _AddAccountDialog({this.onSubmit});
  final void Function(Account account)? onSubmit;

  final _accountType = Rx<AccountType>(AccountType.offline);
  final _formKey = GlobalKey<FormState>();
  final _dropdownBtns = {
    AccountType.offline: "离线账户",
    AccountType.microsoft: "微软账户",
    AccountType.custom: "外置登录"
  };

  @override
  Widget build(BuildContext context) {
    late Account account;
    late _AccountLoginForm form;
    return DefaultDialog(
      title: const Text("添加用户"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 75,
                  child: Text("登录方式"),
                ),
                SizedBox(
                  width: 100,
                  child: Obx(
                    () => DropdownButton(
                      borderRadius: BorderRadius.circular(7.5),
                      isExpanded: true,
                      value: _accountType.value,
                      items: _dropdownBtns.entries
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.key,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  item.value,
                                  style: Get.textTheme.titleSmall,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => _accountType.value = value!,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Form(
              key: _formKey,
              child: Obx(() {
                switch (_accountType.value) {
                  case AccountType.offline:
                    return form = _OfflineLoginForm();
                  // TODO: 支持正版等登录方式
                  case AccountType.microsoft:
                    return form = _MicosoftLoginForm();
                  case AccountType.custom:
                    null;
                }
                return nil;
              }),
            ),
          ],
        ),
      ),
      onConfirmed: () async {
        if (_formKey.currentState!.validate() && onSubmit != null) {
          account = await form.submit();
          onSubmit!(account);
        }
      },
      onCanceled: dialogPop,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<GlobalKey<FormState>>('formKey', _formKey));
  }
}
