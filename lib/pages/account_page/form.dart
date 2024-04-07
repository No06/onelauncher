part of 'account_page.dart';

class _OfflineLoginForm extends HookWidget {
  late final TextEditingController uuidTextController;
  late final TextEditingController usernameTextController;

  static String getUuidFromName(String name) =>
      const Uuid().v5(Uuid.NAMESPACE_NIL, name);

  OfflineAccount submit() => OfflineAccount(
        displayName: usernameTextController.text,
        uuid: uuidTextController.text.replaceAll('-', ''),
      );

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
          getUuidFromName(usernameTextController.text),
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
}

class _MicosoftLoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return nil;
  }

  Future<MicrosoftAccount> submit(String code) async =>
      await MicrosoftAccount.generateByOAuthCode(code);
}
