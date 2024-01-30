part of 'account_page.dart';

abstract mixin class _AccountLoginForm {
  Future<Account> submit();
}

class _OfflineLoginForm extends HookWidget with _AccountLoginForm {
  late final TextEditingController uuidTextController;
  late final TextEditingController usernameTextController;

  @override
  Widget build(BuildContext context) {
    uuidTextController = useTextEditingController();
    usernameTextController = useTextEditingController();
    final rotationAnimationController = useAnimationController(
      upperBound: 0.5,
      duration: const Duration(milliseconds: 250),
    );
    // uuid 监听 用户名变化
    usernameTextController.addListener(
      () => uuidTextController.text =
          OfflineAccount.getUuidFromName(usernameTextController.text),
    );

    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: "用户名"),
          obscureText: false,
          readOnly: false,
          maxLength: 20,
          controller: usernameTextController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp("[\u4e00-\u9fa5_a-zA-Z0-9]"),
            ),
          ],
          validator: noEmpty,
        ),
        ObxValue(
          (p0) => ExpansionListTile(
            isExpaned: p0.value,
            title: ListTile(
              dense: true,
              title: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text("高级"),
                  RotationTransition(
                    turns: rotationAnimationController.view,
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
              onTap: () {
                p0(!p0.value);
                if (p0.value) {
                  rotationAnimationController.forward();
                } else {
                  rotationAnimationController.reverse();
                }
              },
            ),
            expandTile: ListTile(
              dense: true,
              leading: const Text("UUID"),
              title: TextFormField(
                controller: uuidTextController,
                validator: noEmpty,
              ),
            ),
          ),
          false.obs,
        ),
      ],
    );
  }

  @override
  Future<Account> submit() async => OfflineAccount(
        usernameTextController.text,
        uuid: uuidTextController.text,
      );
}

class _MicosoftLoginForm extends HookWidget with _AccountLoginForm {
  late final TextEditingController usernameTextController;

  @override
  Widget build(BuildContext context) {
    usernameTextController = useTextEditingController();
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: "oauth link"),
          obscureText: false,
          readOnly: false,
          controller: usernameTextController,
          validator: noEmpty,
        ),
      ],
    );
  }

  @override
  Future<Account> submit() async {
    var mau = MicrosoftAuthUtil();
    String refreshToken = await mau.doGetMSToken(usernameTextController.text);
    String jwt = await mau.doGetJWT();
    var aiu = AccountInfoUtil(jwt);
    await aiu.getProfile();
    String username = aiu.name;
    String uuid = aiu.uuid;
    return MicrosoftAccount(uuid, username, refreshToken);
  }
}
