import 'dart:async';

import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/account.dart';
import '../theme.dart';
import '/utils/auth/offline/skin.dart';
import '/utils/auth/accounts.dart';
import '/utils/auth/microsoft/microsoft_account.dart';
import '/utils/auth/offline/offline_account.dart';
import '/utils/auth/account.dart';
import '/widgets/page.dart';
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
                builder: (context) => _AddAccountDialog(),
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
        GetX(
          init: AccountController(),
          builder: (c) => Column(
            children: List.generate(
              Accounts.map.length,
              (i) => _AccountItem(
                key: ValueKey(i),
                account: Accounts.map.values.toList()[i],
                isSelected: i == c.currentIndex.value,
                onTap: () => c.currentIndex(i),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountItem extends StatefulWidget {
  const _AccountItem({
    super.key,
    required this.account,
    this.isSelected,
    this.onTap,
  });

  final Account account;
  final bool? isSelected;
  final void Function()? onTap;

  @override
  State<_AccountItem> createState() => _AccountItemState();
}

class _AccountItemState extends State<_AccountItem> {
  final _streamController = StreamController<Uint8List>();
  bool _isPressed = false;
  final boxShadow = const <BoxShadow>[
    BoxShadow(
      color: Colors.black26,
      offset: Offset(0, 2),
      blurRadius: 5,
    ),
  ];

  @override
  void initState() {
    widget.account.skin.u8l
        .then((value) => _streamController.add(Skin.drawAvatar(value!)));
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedColor = colors.primary;
    final unSelectedColor = colorWithValue(colors.surface, .1);
    final fontColor =
        widget.isSelected ?? false ? colors.onPrimary : colors.onSurface;
    bool absorbing = false;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (details) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (details) => setState(() => _isPressed = false),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: SizedBox(
            height: 60,
            child: AnimatedContainer(
              margin: _isPressed
                  ? const EdgeInsets.symmetric(vertical: 1, horizontal: 5)
                  : EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: kBorderRadius,
                boxShadow: boxShadow,
                color: widget.isSelected ?? false
                    ? selectedColor
                    : _isPressed
                        ? selectedColor.withOpacity(.7)
                        : unSelectedColor,
              ),
              child: Row(
                children: [
                  Wrap(
                    spacing: 15,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: -2,
                              blurStyle: BlurStyle.outer,
                            )
                          ],
                        ),
                        child: StreamBuilder<Uint8List>(
                          stream: _streamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            }
                            return const CircularProgressIndicator();
                          },
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.account.username,
                            style: TextStyle(
                              color: fontColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.account is OfflineAccount
                                ? "离线账号"
                                : widget.account is MicrosoftAccount
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
                      AbsorbPointer(
                        absorbing: absorbing,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              absorbing = !absorbing;
                            });
                          },
                          icon: Icon(Icons.checkroom_rounded, color: fontColor),
                        ),
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
                                Accounts.delete(widget.account);
                                final currentIndex =
                                    accountController.currentIndex;
                                if (currentIndex.value != 0 &&
                                    currentIndex.value == Accounts.map.length) {
                                  currentIndex(currentIndex.value - 1);
                                }
                                Get.showSnackbar(successSnackBar("移除成功"));
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
    );
  }
}

class _AddAccountDialog extends StatelessWidget {
  _AddAccountDialog();

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late final items = ["离线账户", "微软账户", "外置登录"];
  late final dropdownItems = List.generate(
    items.length,
    (i) => DropdownMenuItem(
      value: AccountLoginMode.values[i],
      child: Container(
        alignment: Alignment.center,
        child: Text(
          items[i],
          style: Get.textTheme.titleSmall,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    var loginMode = AccountLoginMode.offline.obs;

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
                      value: loginMode.value,
                      items: dropdownItems,
                      onChanged: (value) => loginMode(value),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Obx(
              () => Form(
                key: formKey,
                child: Column(
                  children: switch (loginMode()) {
                    AccountLoginMode.offline => [
                        TextFormField(
                          decoration: const InputDecoration(labelText: "用户名"),
                          obscureText: false,
                          readOnly: false,
                          maxLength: 20,
                          controller: username,
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
                    AccountLoginMode.ms => [],
                    AccountLoginMode.custom => [],
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      onConfirmed: () {
        dialogPop();
        if (formKey.currentState!.validate()) {
          switch (loginMode.value) {
            case AccountLoginMode.offline:
              Accounts.add(OfflineAccount(username.text));
            // TODO: 正版验证
            case AccountLoginMode.ms:
            // TODO: 第三方登录
            case AccountLoginMode.custom:
          }
          Get.showSnackbar(successSnackBar("添加成功！"));
        }
      },
      onCanceled: () => dialogPop(),
    );
  }
}
