import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:one_launcher/widgets/route_page.dart';

import '../models/theme_config.dart';
import '../models/account/microsoft_account.dart';
import '../models/account/offline_account.dart';
import '../models/account/account.dart';
import '/widgets/dialog.dart';
import '../widgets/snackbar.dart';

class AccountPage extends RoutePage {
  const AccountPage({super.key, required super.pageName});

  @override
  Widget body(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Column(
                children: () {
                  final results = <Widget>[];
                  for (var account in appConfig.accounts) {
                    results.add(
                      ValueListenableBuilder(
                        key: UniqueKey(),
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
                            } catch (e) {
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

// TODO: 加载卡顿
class _AccountItem extends StatelessWidget {
  const _AccountItem({
    super.key,
    required this.account,
    this.isSelected = false,
    this.onTap,
    this.onRemoved,
  });

  final Account account;
  final bool isSelected;
  final void Function()? onTap;
  final void Function(Account account)? onRemoved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedColor = colors.primary;
    final unSelectedColor = colorWithValue(colors.surface, .1);
    final fontColor = isSelected ? colors.onPrimary : colors.onSurface;
    final isTapDown = false.obs;
    final isHover = false.obs;

    return GestureDetector(
      onTap: onTap,
      onTapDown: (details) => isTapDown(true),
      onTapCancel: () => isTapDown(false),
      onTapUp: (details) => isTapDown(false),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => isHover(true),
        onExit: (event) => isHover(false),
        child: Container(
          height: 58,
          margin: const EdgeInsets.only(bottom: 12),
          child: Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: isTapDown.value
                  ? const EdgeInsets.symmetric(vertical: 1, horizontal: 5)
                  : EdgeInsets.zero,
              child: Material(
                elevation: isTapDown.value ? 0 : 3,
                shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
                clipBehavior: Clip.antiAlias,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  color: isSelected
                      ? selectedColor
                      : isTapDown.value
                          ? selectedColor.withOpacity(.7)
                          : isHover.value
                              ? dynamicColorWithValue(
                                  unSelectedColor, -0.1, 0.1, theme.brightness)
                              : unSelectedColor,
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
                                      final future = useMemoized(
                                          () => account.skin.drawAvatar());
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
    );
  }
}

class _AddAccountDialog extends HookWidget {
  _AddAccountDialog({this.onSubmit});
  final void Function(Account account)? onSubmit;

  final _accountType = AccountType.offline.obs;
  final _formKey = GlobalKey<FormState>();
  final _dropdownBtns = {
    AccountType.offline: "离线账户",
    AccountType.microsoft: "微软账户",
    AccountType.custom: "外置登录"
  };

  @override
  Widget build(BuildContext context) {
    final usernameTextCtl = useTextEditingController();
    late Account account;
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
            Obx(
              () => Form(
                key: _formKey,
                child: Column(
                  children: switch (_accountType.value) {
                    AccountType.offline => [
                        TextFormField(
                          decoration: const InputDecoration(labelText: "用户名"),
                          obscureText: false,
                          readOnly: false,
                          maxLength: 20,
                          controller: usernameTextCtl,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp("[\u4e00-\u9fa5_a-zA-Z0-9]"),
                            ),
                          ],
                          validator: (value) =>
                              value == null || value.isEmpty ? "此处不能为空" : null,
                        ),
                      ],
                    // TODO: 正版登录等支持
                    AccountType.microsoft => [],
                    AccountType.custom => [],
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      onConfirmed: () {
        if (_formKey.currentState!.validate()) {
          switch (_accountType.value) {
            case AccountType.offline:
              account = OfflineAccount(usernameTextCtl.text);
            case AccountType.microsoft:
            // TODO: Handle this case.
            case AccountType.custom:
            // TODO: Handle this case.
          }
          (onSubmit ?? () {})(account);
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
