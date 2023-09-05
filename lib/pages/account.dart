import 'package:beacon/consts.dart';
import 'package:beacon/models/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/theme_config.dart';
import '../models/microsoft_account.dart';
import '../models/offline_account.dart';
import '../models/account.dart';
import '../widgets/route_page.dart';
import '/widgets/dialog.dart';
import '../widgets/snackbar.dart';

class AccountPage extends RoutePage {
  const AccountPage({super.key});

  @override
  String routeName() => "用户";

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(15),
      children: [
        Row(
          children: [
            title(),
            const Spacer(),
            FilledButton(
              onPressed: () => showDialog(
                context: Get.context!,
                builder: (context) => _AddAccountDialog(
                  onSubmit: (account) {
                    appConfig.accounts.add(account);
                    appConfig.selectedAccount ??= account;
                    Get.showSnackbar(successSnackBar("添加成功！"));
                  },
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.add),
                    Text("添加用户"),
                    SizedBox(width: 7),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(
          () => Column(
            children: appConfig.accounts
                .map(
                  (account) => ValueListenableBuilder(
                    valueListenable: appConfig.selectedAccountNotifier,
                    builder: (_, selectedAccount, __) => _AccountItem(
                      key: ValueKey(account.uuid),
                      account: account,
                      isSelected: appConfig.selectedAccount == account,
                      onTap: () => appConfig.selectedAccount = account,
                      onRemoved: (account) {
                        appConfig.accounts.remove(account);
                        try {
                          appConfig.selectedAccount = appConfig.accounts.first;
                        } catch (e) {
                          appConfig.selectedAccount = null;
                        }
                        Get.showSnackbar(successSnackBar("删除成功"));
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _AccountItem extends StatelessWidget {
  _AccountItem({
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
  final _isTapDown = false.obs;
  bool get isTapDown => _isTapDown.value;
  set isTapDown(bool newVal) => _isTapDown.value = newVal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedColor = colors.primary;
    final unSelectedColor = colorWithValue(colors.surface, .1);
    final fontColor = isSelected ? colors.onPrimary : colors.onSurface;

    return GestureDetector(
      onTap: onTap,
      onTapDown: (details) => isTapDown = true,
      onTapCancel: () => isTapDown = false,
      onTapUp: (details) => isTapDown = false,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 58,
          margin: const EdgeInsets.only(bottom: 8),
          child: Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: isTapDown
                  ? const EdgeInsets.symmetric(vertical: 1, horizontal: 5)
                  : EdgeInsets.zero,
              child: Material(
                elevation: isTapDown ? 0 : 3,
                shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
                clipBehavior: Clip.antiAlias,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  color: isSelected
                      ? selectedColor
                      : isTapDown
                          ? selectedColor.withOpacity(.7)
                          : unSelectedColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Wrap(
                          spacing: 15,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              // TODO: 头像显示
                              child: FutureBuilder(
                                future: account.skin.u8l,
                                builder: (_, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasError) {
                                      return const Icon(Icons.error);
                                    } else {
                                      Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                  }
                                  return CircularProgressIndicator(
                                    color: isSelected ? colors.onPrimary : null,
                                  );
                                },
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
                                  builder: (context) => DefaultDialog(
                                    title: const Text("移除用户"),
                                    content: Text(
                                      "你确定要移除这个用户吗？此操作将无法撤销！",
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    onConfirmed: () {
                                      dialogPop();
                                      (onRemoved ?? () {})(account);
                                    },
                                    onCanceled: () => dialogPop(),
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

class _AddAccountDialog extends StatelessWidget {
  _AddAccountDialog({this.onSubmit});
  final void Function(Account account)? onSubmit;

  late final Account account;

  final _accountType = AccountType.offline.obs;
  final _username = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _dropdownBtns = {
    AccountType.offline: "离线账户",
    AccountType.microsoft: "微软账户",
    AccountType.custom: "外置登录"
  };

  @override
  Widget build(BuildContext context) {
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
                          controller: _username,
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
        dialogPop();
        if (_formKey.currentState!.validate()) {
          switch (_accountType.value) {
            case AccountType.offline:
              account = OfflineAccount(_username.text);
            case AccountType.microsoft:
            // TODO: Handle this case.
            case AccountType.custom:
            // TODO: Handle this case.
          }
          (onSubmit ?? () {})(account);
        }
      },
      onCanceled: () => dialogPop(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<GlobalKey<FormState>>('formKey', _formKey));
  }
}
