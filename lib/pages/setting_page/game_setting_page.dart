part of 'setting_page.dart';

class _GameSettingPage extends _SettingBasePage {
  const _GameSettingPage();

  @override
  Widget body(BuildContext context) {
    return Theme(
      data: simpleInputDecorationThemeData(context),
      child: const Column(
        children: [
          _JavaSettingEditListTileGroup(),
          _MemorySettingListTileGroup(),
          _GameSettingListTileGroup(),
        ],
      ),
    );
  }
}

class _JavaSettingEditListTileGroup extends StatelessWidget {
  const _JavaSettingEditListTileGroup();

  Future<void> _onPressedJvmArgsEdit(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const _JvmArgsEditDialog(),
    );
    if (result != null) {
      ref.read(gameSettingProvider.notifier).update(jvmArgs: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TitleWidgetGroup(
      "Java",
      children: [
        ListTile(
          title: const Text("Java路径"),
          subtitle: Consumer(
            builder: (context, ref, child) {
              final path = ref
                  .watch(gameSettingProvider.select((state) => state.java))
                  ?.path;
              return Text(path ?? "自动选择最佳版本");
            },
          ),
          onTap: () => showDialog<void>(
            context: context,
            builder: (context) => const _JavaSelectDialog(),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final jvmArgs =
                ref.watch(gameSettingProvider.select((state) => state.jvmArgs));
            final useDefaultJvmArgs =
                ref.read(gameSettingProvider).useDefaultJvmArgs;
            return ListTile(
              title: const Text("JVM启动参数"),
              subtitle: Text(
                useDefaultJvmArgs ? "默认" : jvmArgs!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _onPressedJvmArgsEdit(context, ref),
            );
          },
        ),
      ],
    );
  }
}

/// 返回jvm启动项字符串
class _JvmArgsEditDialog extends HookConsumerWidget {
  const _JvmArgsEditDialog();

  Future<void> _onPressedResetArgs(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => WarningDialog(
        content: const Text("你确定要重置吗？"),
        onConfirmed: () => dialogPop(result: true),
      ),
    );
    if (result ?? false) controller.clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jvmArgs = ref.read(gameSettingProvider).jvmArgs;
    final useDefaultJvmArgs = ref.read(gameSettingProvider).useDefaultJvmArgs;
    final controller =
        useTextEditingController(text: useDefaultJvmArgs ? null : jvmArgs);

    return DefaultDialog(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("JVM启动参数"),
          IconButton(
            onPressed: () => _onPressedResetArgs(context, controller),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      confirmText: const Text("保存"),
      onCanceled: dialogPop,
      onConfirmed: () => dialogPop(result: controller.text),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 400,
            child: Theme(
              data: simpleInputDecorationThemeData(context),
              child: TextField(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}

/// 返回null
class _JavaSelectDialog extends StatelessWidget {
  const _JavaSelectDialog();

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: const Text("Java路径"),
      onlyConfirm: true,
      confirmText: const Text("返回"),
      onConfirmed: dialogPop,
      content: Material(
        color: Colors.transparent,
        borderRadius: kDefaultBorderRadius,
        child: SingleChildScrollView(
          child: Consumer(
            builder: (context, ref, child) {
              final java =
                  ref.watch(gameSettingProvider.select((state) => state.java));
              final notifier = ref.read(gameSettingProvider.notifier);
              return Column(
                children: [
                  RadioListTile(
                    value: null,
                    groupValue: java,
                    title: const Text("自动选择最佳版本"),
                    onChanged: (value) => notifier.update(java: value),
                  ),
                  ...JavaManager.set.map(
                    (e) => RadioListTile(
                      value: e,
                      groupValue: java,
                      title: Text(e.version),
                      subtitle: Text(e.path),
                      onChanged: (value) => notifier.update(java: value),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MemorySettingListTileGroup extends HookConsumerWidget {
  const _MemorySettingListTileGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textController = useTextEditingController(
      text: ref.read(gameSettingProvider).maxMemory.toString(),
    );

    void updateText(String newVal) => textController.text = newVal;
    updateMaxMemory() {
      ref
          .read(gameSettingProvider.notifier)
          .update(maxMemory: int.parse(textController.text));
    }

    final textFieldFocusNode = useFocusNode();

    listener() {
      if (!textFieldFocusNode.hasFocus) updateMaxMemory();
    }

    useEffect(
      () {
        textFieldFocusNode.addListener(listener);
        return () => textFieldFocusNode.removeListener(listener);
      },
      [textFieldFocusNode],
    );

    return TitleWidgetGroup(
      "内存",
      children: [
        Consumer(
          builder: (context, ref, child) {
            final autoMemory = ref
                .watch(gameSettingProvider.select((state) => state.autoMemory));
            return ExpansionListTile(
              isExpaned: !autoMemory,
              title: SwitchListTile(
                title: const Text("游戏内存"),
                subtitle: const Text("自动分配"),
                value: autoMemory,
                selected: autoMemory,
                hoverColor: colors.secondaryContainer.withValue(-.05),
                onChanged: (value) => ref
                    .read(gameSettingProvider.notifier)
                    .update(autoMemory: value),
              ),
              child: child!,
            );
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    const Text("手动分配"),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: textController,
                        builder: (context, textValue, child) => Slider(
                          inactiveColor: colors.primary.withOpacity(.2),
                          value: double.parse(textValue.text),
                          min: 1,
                          max: sysinfo.totalPhyMem.toMB(),
                          label: textValue.text,
                          onChanged: (value) =>
                              updateText(value.toInt().toString()),
                          onChangeEnd: (value) {
                            final intValue = value.toInt();
                            updateText(intValue.toString());
                            updateMaxMemory();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: SizedBox(
                        width: 100,
                        height: 36,
                        child: TextField(
                          focusNode: textFieldFocusNode,
                          controller: textController,
                          inputFormatters: [
                            _MemoryTextInputFormatter(
                              sysinfo.totalPhyMem.toMB().toInt(),
                            ),
                          ],
                          decoration: const InputDecoration(
                            suffixIcon: SizedBox.shrink(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text("MB"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                child: ValueListenableBuilder(
                  valueListenable: textController,
                  builder: (context, value, child) =>
                      _MemoryAllocationBar(double.parse(value.text) / 1024),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameSettingListTileGroup extends ConsumerWidget {
  const _GameSettingListTileGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameSettingProvider.notifier);
    return TitleWidgetGroup(
      "游戏",
      children: [
        Consumer(
          builder: (context, ref, child) {
            final fullScreen = ref
                .watch(gameSettingProvider.select((state) => state.fullScreen));
            return ExpansionListTile(
              isExpaned: !fullScreen,
              title: SwitchListTile(
                value: fullScreen,
                selected: fullScreen,
                title: const Text("全屏"),
                onChanged: (value) => notifier.update(fullScreen: value),
              ),
              child: child!,
            );
          },
          child: ListTile(
            title: const Text("自定义分辨率"),
            trailing: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 65,
                    child: Consumer(
                      builder: (context, ref, child) =>
                          _ResolutionEditTextField(
                        value: ref.watch(
                          gameSettingProvider.select((state) => state.width),
                        ),
                        onSubmitted: (value) =>
                            notifier.update(width: int.parse(value)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("X"),
                  ),
                  SizedBox(
                    width: 65,
                    child: Consumer(
                      builder: (context, ref, child) =>
                          _ResolutionEditTextField(
                        value: ref.watch(
                          gameSettingProvider.select((state) => state.height),
                        ),
                        onSubmitted: (value) =>
                            notifier.update(height: int.parse(value)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final recordLog = ref
                .watch(gameSettingProvider.select((state) => state.recordLog));
            return SwitchListTile(
              value: recordLog,
              selected: recordLog,
              title: const Text("日志"),
              onChanged: (value) => notifier.update(recordLog: value),
            );
          },
        ),
        ListTile(
          title: const Text("启动参数"),
          trailing: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _TextField(
                text:
                    ref.read(gameSettingProvider.select((state) => state.args)),
                onNoFocus: (value) => notifier.update(args: value),
                onSubmitted: (value) => notifier.update(args: value),
              ),
            ),
          ),
        ),
        ListTile(
          title: const Text("自动加入服务器地址"),
          trailing: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _TextField(
                text: ref.read(
                  gameSettingProvider.select((state) => state.serverAddress),
                ),
                onNoFocus: (value) => notifier.update(serverAddress: value),
                onChanged: (value) => notifier.update(serverAddress: value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

typedef TextFieldCallback = void Function(String);

class _ResolutionEditTextField extends HookWidget {
  const _ResolutionEditTextField({
    required this.value,
    required this.onSubmitted,
  });

  final int value;
  final TextFieldCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final textCtl = useTextEditingController(text: value.toString());
    final focusNode = useFocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus && onSubmitted != null) {
        onSubmitted!(textCtl.text);
      }
      return;
    });
    return TextField(
      controller: textCtl,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      maxLength: 4,
      decoration: const InputDecoration(counterText: ""),
      onSubmitted: onSubmitted,
    );
  }
}

class _TextField extends HookWidget {
  const _TextField({
    required this.text,
    this.onSubmitted,
    this.onNoFocus,
    this.onChanged,
  });

  final String text;
  final TextFieldCallback? onSubmitted;
  final TextFieldCallback? onNoFocus;
  final TextFieldCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final textCtl = useTextEditingController(text: text);
    final focusNode = useFocusNode();

    useEffect(
      () {
        listener() {
          if (!focusNode.hasFocus && onNoFocus != null) {
            onNoFocus!(textCtl.text);
          }
        }

        focusNode.addListener(listener);
        return () => focusNode.removeListener(listener);
      },
      [focusNode],
    );

    return TextField(
      controller: textCtl,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}

class _MemoryAllocationBar extends StatefulWidget {
  const _MemoryAllocationBar(this.allocationMemSize);

  final double allocationMemSize;

  @override
  State<_MemoryAllocationBar> createState() => _MemoryAllocationBarState();
}

class _MemoryAllocationBarState extends State<_MemoryAllocationBar> {
  late final Timer timer;
  late double totalPhyMem;
  late double freePhyMem;

  @override
  void initState() {
    super.initState();
    updateMemInfo();
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => setState(updateMemInfo),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void updateMemInfo() {
    totalPhyMem = sysinfo.totalPhyMem.toGB();
    freePhyMem = sysinfo.freePhyMem.toGB();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final allocationMemPercent = widget.allocationMemSize / totalPhyMem;
    final usedMemSize = totalPhyMem - freePhyMem;
    final usedPercent = usedMemSize / totalPhyMem;
    return Column(
      children: [
        SizedBox(
          height: 5,
          child: ClipRRect(
            borderRadius: kDefaultBorderRadius,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(.2),
                    borderRadius: kDefaultBorderRadius,
                  ),
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 100),
                  widthFactor: usedPercent + allocationMemPercent,
                  child: Container(color: colors.primary.withOpacity(.3)),
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 100),
                  widthFactor: usedPercent,
                  child: Container(color: colors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              "使用中内存：${usedMemSize.toDecimal()} / ${totalPhyMem.toDecimal()} GB",
            ),
            const Spacer(),
            Text(
              "游戏分配：${widget.allocationMemSize.toDecimal()} GB ${widget.allocationMemSize > freePhyMem ? "(${freePhyMem.toDecimal()} GB 可用)" : ""}",
            ),
          ],
        ),
      ],
    );
  }
}

class _MemoryTextInputFormatter extends TextInputFormatter {
  const _MemoryTextInputFormatter(this.maxSize);

  final int maxSize;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty ||
        newValue.text.startsWith('0') ||
        !newValue.text.isNum ||
        newValue.text.substring(newValue.text.length - 1) == '.' ||
        int.parse(newValue.text) > maxSize) {
      return oldValue;
    }
    return newValue;
  }
}
