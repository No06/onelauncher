part of 'account_page.dart';

class _AccountItem extends ConsumerWidget {
  const _AccountItem({
    super.key,
    required this.account,
  });

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
        accountProvider.select((state) => state.selectedAccount == account));

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedColor = colors.primary;
    final unSelectedColor = colorWithValue(colors.surface, .1);
    final fontColor = isSelected ? colors.onPrimary : colors.onSurface;

    final isTapDown = RxBool(false);
    final isHover = RxBool(false);

    Color getColor() {
      if (isSelected) {
        return selectedColor;
      }
      if (isTapDown.value) {
        return selectedColor.withOpacity(.7);
      }
      if (isHover.value) {
        return dynamicColorWithValue(
            unSelectedColor, -0.1, 0.1, theme.brightness);
      }
      return unSelectedColor;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 58,
        child: GestureDetector(
          onTap: () =>
              ref.read(accountProvider.notifier).updateSelectedAccount(account),
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
                  shape: const RoundedRectangleBorder(
                      borderRadius: kDefaultBorderRadius),
                  clipBehavior: Clip.antiAlias,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    color: getColor(),
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
                              _Avatar(account, isSelected),
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
                          _Actions(account, fontColor),
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

// FIXME: 头像第一次加载卡顿
class _Avatar extends HookWidget {
  const _Avatar(this.account, this.isSelected);

  final Account account;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SizedBox(
      width: 40,
      height: 40,
      child: HookBuilder(
        builder: (context) {
          final future =
              useMemoized(() async => (await account.getSkin()).drawAvatar());
          final snapshot = useFuture(future);
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              if (kDebugMode) debugPrint(snapshot.error!.toString());
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
              color: isSelected ? colors.onPrimary : null,
            ),
          );
        },
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions(this.account, this.fontColor);

  final Account account;
  final Color fontColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 5,
      children: [
        if (account is MicrosoftAccount)
          IconButton(
            onPressed: () {
              (account as MicrosoftAccount).getProfile();
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
              icon: Icon(Icons.checkroom_rounded, color: fontColor),
            ),
          ),
          false.obs,
        ),
        IconButton(
          icon: Icon(Icons.delete, color: fontColor),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => WarningDialog(
                title: const Text("删除用户"),
                content: const Text("你确定要删除这条数据吗？"),
                onConfirmed: () {
                  ref.read(accountProvider.notifier).removeAccount(account);
                  showSnackbar(successSnackBar("删除成功"));
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
