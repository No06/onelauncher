part of 'account_page.dart';

class _AccountItem extends HookConsumerWidget {
  const _AccountItem({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedColor = colors.primary;
    final unSelectedColor = colorWithValue(colors.surface, .1);
    final hoverColor =
        dynamicColorWithValue(unSelectedColor, -0.1, 0.1, theme.brightness);
    final tapDownColor = selectedColor.withValue(.15);

    final isHover = useValueNotifier(false);
    final isTapDown = useValueNotifier(false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 58,
        child: GestureDetector(
          onTap: () =>
              ref.read(accountProvider.notifier).updateSelectedAccount(account),
          onTapDown: (details) => isTapDown.value = true,
          onTapCancel: () => isTapDown.value = false,
          onTapUp: (details) => isTapDown.value = false,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) => isHover.value = true,
            onExit: (event) => isHover.value = false,
            child: Consumer(
              builder: (context, ref, child) {
                final isSelected = ref.watch(accountProvider
                    .select((state) => state.selectedAccount == account));

                return MultiValueListenableBuilder(
                  valueListenables: [isHover, isTapDown],
                  builder: (context, values, child) => AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      boxShadow: isTapDown.value ? null : kElevationToShadow[1],
                      borderRadius: kDefaultBorderRadius,
                      color: () {
                        if (isSelected) return selectedColor;
                        if (isTapDown.value) return tapDownColor;
                        if (isHover.value) return hoverColor;
                        return unSelectedColor;
                      }(),
                    ),
                    margin: isTapDown.value
                        ? const EdgeInsets.symmetric(vertical: 1, horizontal: 5)
                        : EdgeInsets.zero,
                    child: child,
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Consumer(builder: (context, ref, child) {
                  final isSelected = ref.watch(accountProvider
                      .select((state) => state.selectedAccount == account));
                  final fontColor =
                      isSelected ? colors.onPrimary : colors.onSurface;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: 15,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Avatar(account, isSelected: isSelected),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                      _Actions(account, fontColor: fontColor),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// FIXME: 头像第一次加载卡顿
class _Avatar extends StatefulWidget {
  const _Avatar(this.account, {required this.isSelected});

  final Account account;
  final bool isSelected;

  @override
  State<_Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<_Avatar> {
  late final drawAvatar = Future(() async {
    final skin = await widget.account.getSkin();
    return skin.drawAvatar();
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SizedBox(
      width: 40,
      height: 40,
      child: FutureBuilder(
        future: drawAvatar,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              snapshot.error.printError("Account avatar request error");
              return const Icon(Icons.error);
            }
            return Padding(
              padding: const EdgeInsets.all(1),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Image.memory(
                  snapshot.data!,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(4),
            child: CircularProgressIndicator(
              color: widget.isSelected ? colors.onPrimary : null,
            ),
          );
        },
      ),
    );
  }
}

class _Actions extends StatefulHookConsumerWidget {
  const _Actions(this.account, {required this.fontColor})
      : isMSAccount = account is MicrosoftAccount;

  final Account account;
  final Color fontColor;
  final bool isMSAccount;

  @override
  ConsumerState<_Actions> createState() => _ActionsState();
}

class _ActionsState extends ConsumerState<_Actions> {
  @override
  Widget build(BuildContext context) {
    final updating = useValueNotifier(false);
    updateProfile() {
      updating.value = true;
      ref
          .read(accountProvider.notifier)
          .updateAccountProfile(widget.account as MicrosoftAccount)
          .then((_) {
        setState(() {
          updating.value = false;
        });
      });
    }

    return Wrap(
      spacing: 5,
      children: [
        if (widget.isMSAccount)
          ValueListenableBuilder(
            valueListenable: updating,
            builder: (context, updating, child) => IconButton(
              onPressed: updating ? null : updateProfile,
              icon: Icon(Icons.refresh,
                  color: widget.fontColor.withOpacity(updating ? .5 : 1)),
            ),
          ),
        AbsorbPointer(
          absorbing: false,
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.checkroom_rounded, color: widget.fontColor),
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: widget.fontColor),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => WarningDialog(
                title: const Text("删除用户"),
                content: const Text("你确定要删除这条数据吗？"),
                onConfirmed: () {
                  ref
                      .read(accountProvider.notifier)
                      .removeAccount(widget.account);
                  showSnackbar(successSnackBar(title: "删除成功"));
                  dialogPop();
                },
                onCanceled: dialogPop,
              ),
            );
          },
        ),
      ],
    );
  }
}
