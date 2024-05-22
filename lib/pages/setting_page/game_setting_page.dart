part of 'setting_page.dart';

class _GameSettingPage extends _SettingBasePage {
  const _GameSettingPage({required this.config});

  final GameSettingConfig config;

  @override
  Widget body(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      children: [
        TitleWidgetGroup(
          "Java",
          children: [
            ListTile(
              title: const Text("Java路径"),
              subtitle: () {
                return ValueListenableBuilder(
                  valueListenable: config.javaNotifier,
                  builder: (_, java, __) {
                    String text;
                    var java = config.java;
                    if (java == null) {
                      text = "自动选择最佳版本";
                    } else {
                      text = "${java.version} - ${java.path}";
                    }
                    return Text(text);
                  },
                );
              }(),
              onTap: () => showDialog(
                context: Get.context!,
                builder: (_) {
                  return DefaultDialog(
                    title: const Text("Java路径"),
                    onlyConfirm: true,
                    confirmText: const Text("返回"),
                    onConfirmed: dialogPop,
                    content: Material(
                      color: Colors.transparent,
                      borderRadius: kDefaultBorderRadius,
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        child: ValueListenableBuilder(
                          valueListenable: config.javaNotifier,
                          builder: (_, java, __) => Column(
                            children: [
                                  RadioListTile(
                                    value: null,
                                    groupValue: java,
                                    title: const Text("自动选择最佳版本"),
                                    onChanged: (value) => config.java = value,
                                  ),
                                ] +
                                JavaManager.set
                                    .map(
                                      (e) => RadioListTile(
                                        value: e,
                                        groupValue: java,
                                        title: Text(e.version),
                                        subtitle: Text(e.path),
                                        onChanged: (value) =>
                                            config.java = value,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              title: const Text("JVM启动参数"),
              subtitle: ValueListenableBuilder(
                valueListenable: config.jvmArgsNotifier,
                builder: (context, value, child) {
                  return Text(
                    config.jvmArgsIsEmpty ? "默认" : value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              onTap: () => showDialog(
                context: Get.context!,
                builder: (_) => HookBuilder(
                  builder: (context) {
                    final controller = useTextEditingController(
                        text: config.jvmArgsNotifier.value);
                    return DefaultDialog(
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("JVM启动参数"),
                          IconButton(
                            onPressed: () => showDialog(
                              context: Get.context!,
                              builder: (_) => WarningDialog(
                                content: const Text("你确定要重置吗？"),
                                onConfirmed: () {
                                  dialogPop();
                                  controller.clear();
                                },
                              ),
                            ),
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      confirmText: const Text("保存"),
                      onCanceled: dialogPop,
                      onConfirmed: () {
                        dialogPop();
                        config.jvmArgs = controller.text;
                      },
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 400,
                            child: Theme(
                              data: simpleInputDecorationThemeData(context),
                              child: TextField(
                                controller: controller,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        HookBuilder(builder: (context) {
          final textController =
              useTextEditingController(text: config.maxMemory.toString());
          textController.addListener(
              () => config.maxMemory = int.parse(textController.text));
          return TitleWidgetGroup(
            "内存",
            children: [
              ValueBuilder<bool?>(
                initialValue: config.autoMemory,
                builder: (value, updater) {
                  return ExpansionListTile(
                    isExpaned: !value!,
                    title: SwitchListTile(
                      title: const Text("游戏内存"),
                      subtitle: const Text("自动分配"),
                      value: value,
                      selected: value,
                      hoverColor:
                          colorWithValue(colors.secondaryContainer, -.05),
                      onChanged: (value) {
                        config.autoMemory = value;
                        updater(value);
                      },
                    ),
                    expandTile: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            children: [
                              const Text("手动分配"),
                              Expanded(
                                child: ValueListenableBuilder(
                                  valueListenable: textController,
                                  builder: (context, textValue, child) =>
                                      Slider(
                                    inactiveColor:
                                        colors.primary.withOpacity(.2),
                                    value: double.parse(textValue.text),
                                    min: 1,
                                    max: sysinfo.totalPhyMem.toMB(),
                                    label: textValue.text,
                                    onChanged: (value) => textController.text =
                                        value.toInt().toString(),
                                    onChangeEnd: (value) => textController
                                        .text = value.toInt().toString(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: SizedBox(
                                  width: 100,
                                  height: 36,
                                  child: Theme(
                                    data:
                                        simpleInputDecorationThemeData(context),
                                    child: TextField(
                                      controller: textController,
                                      inputFormatters: [
                                        MemoryTextInputFormatter(
                                            sysinfo.totalPhyMem.toMB().toInt())
                                      ],
                                      onChanged: (value) =>
                                          config.maxMemory = int.parse(value),
                                      decoration: const InputDecoration(
                                        suffixIcon: SizedBox.shrink(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: Text("MB"),
                                            ),
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
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 10),
                          child: HookBuilder(builder: (context) {
                            return ValueListenableBuilder(
                              valueListenable: config.maxMemoryNotifier,
                              builder: (_, maxMemory, __) {
                                return _MemoryAllocationBar(
                                  config.maxMemory.toDouble() / 1024,
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }),
        TitleWidgetGroup(
          "游戏",
          children: [
            ValueBuilder<bool?>(
              initialValue: config.fullScreen,
              builder: (value, updater) => ExpansionListTile(
                isExpaned: !value!,
                title: SwitchListTile(
                  value: value,
                  selected: value,
                  title: const Text("全屏"),
                  onChanged: (value) {
                    config.fullScreen = value;
                    updater(value);
                  },
                ),
                expandTile: ListTile(
                  title: const Text("自定义分辨率"),
                  trailing: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7.5),
                    child: Theme(
                      data: simpleInputDecorationThemeData(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 65,
                            child: _ResolutionTextField(
                              value: config.width,
                              onSubmitted: (value) {
                                config.width = int.parse(value);
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("X"),
                          ),
                          SizedBox(
                            width: 65,
                            child: _ResolutionTextField(
                              value: config.height,
                              onSubmitted: (value) {
                                config.height = int.parse(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ValueBuilder<bool?>(
              initialValue: config.log,
              builder: (value, updater) => SwitchListTile(
                value: value!,
                selected: value,
                title: const Text("日志"),
                onChanged: (value) {
                  updater(value);
                  config.log = value;
                },
              ),
            ),
            ListTile(
              title: const Text("启动参数"),
              trailing: SizedBox(
                width: 300,
                child: Theme(
                  data: simpleInputDecorationThemeData(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: _TextField(
                      text: config.args,
                      onSubmitted: (value) {
                        config.args = value;
                      },
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text("自动加入服务器地址"),
              trailing: SizedBox(
                width: 300,
                child: Theme(
                  data: simpleInputDecorationThemeData(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: _TextField(
                      text: config.serverAddress,
                      onChanged: (value) {
                        config.serverAddress = value;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

typedef TextFieldCallback = void Function(String);

class _ResolutionTextField extends HookWidget {
  const _ResolutionTextField({
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
      decoration: const InputDecoration(
        counterText: "",
      ),
      onSubmitted: onSubmitted,
    );
  }
}

class _TextField extends HookWidget {
  const _TextField({
    required this.text,
    this.onSubmitted,
    this.onChanged,
  });

  final String text;
  final TextFieldCallback? onSubmitted;
  final TextFieldCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final textCtl = useTextEditingController(text: text);
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
  var needUpdate = true;
  late double totalPhyMem;
  late double freePhyMem;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 3), (timer) => setState(updateMemInfo));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void updateMemInfo() {
    if (!needUpdate) return;
    needUpdate = false;
    totalPhyMem = sysinfo.totalPhyMem.toGB();
    freePhyMem = sysinfo.freePhyMem.toGB();
    Future.delayed(Durations.extralong4).then((value) => needUpdate = true);
  }

  @override
  Widget build(BuildContext context) {
    updateMemInfo();
    final colors = Theme.of(context).colorScheme;
    final allocationMemPercent = widget.allocationMemSize / totalPhyMem;
    final usedMemSize = totalPhyMem - freePhyMem;
    final usedPercent = usedMemSize / totalPhyMem;
    return Column(
      children: [
        SizedBox(
          height: 5,
          child: ClipRRect(
            clipBehavior: Clip.antiAlias,
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
                "使用中内存：${_toDecimal(usedMemSize)} / ${_toDecimal(totalPhyMem)} GB"),
            const Spacer(),
            Text(
                "游戏分配：${_toDecimal(widget.allocationMemSize)} GB ${widget.allocationMemSize > freePhyMem ? "(${_toDecimal(freePhyMem)} GB 可用)" : ""}"),
          ],
        ),
      ],
    );
  }
}

class MemoryTextInputFormatter extends TextInputFormatter {
  const MemoryTextInputFormatter(this.maxSize);

  final int maxSize;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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

// 保留小数
double _toDecimal(num value, [int fractionalDigits = 1]) =>
    (value * pow(10, fractionalDigits)).truncate() / pow(10, fractionalDigits);
