part of '../account_page.dart';

final _isExpanedProvider = StateProvider.autoDispose((ref) => false);

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
    useEffect(() {
      listener() => uuidTextController.text =
          getUuidFromName(usernameTextController.text);
      usernameTextController.addListener(listener);
      return () => usernameTextController.removeListener(listener);
    }, [usernameTextController]);

    return Theme(
      data: simpleInputDecorationThemeData(context),
      child: Column(
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
            validator: FormValidator.noEmpty,
          ),
          Consumer(
            builder: (context, ref, child) {
              final isExpaned = ref.watch(_isExpanedProvider);
              return ExpansionListTile(
                isExpaned: isExpaned,
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
                    ref.read(_isExpanedProvider.notifier).state = !isExpaned;
                    if (!isExpaned) {
                      rotationAnimationController.forward();
                    } else {
                      rotationAnimationController.reverse();
                    }
                  },
                ),
                child: child!,
              );
            },
            child: ListTile(
              dense: true,
              leading: const Text("UUID"),
              title: TextFormField(
                decoration: const InputDecoration(
                  constraints: BoxConstraints(maxHeight: 36),
                ),
                controller: uuidTextController,
                validator: FormValidator.noEmpty,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
