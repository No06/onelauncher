import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/config/game_setting_config.dart';
import 'package:one_launcher/models/config/theme_config.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:one_launcher/utils/sys_info/sys_info.dart';
import 'package:one_launcher/utils/sys_info/sys_info_linux.dart';
import 'package:one_launcher/utils/sys_info/sys_info_macos.dart';
import 'package:one_launcher/utils/sys_info/sys_info_windows.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:one_launcher/widgets/textfield.dart';
import 'package:one_launcher/widgets/widget_group.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

abstract class SettingBasePage extends StatelessWidget {
  const SettingBasePage({super.key});

  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return DynMouseScroll(
      animationCurve: kMouseScrollAnimationCurve,
      builder: (context, controller, physics) => ListView(
        controller: controller,
        physics: physics,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [body(context)],
      ),
    );
  }
}

class GameSettingPage extends SettingBasePage {
  GameSettingPage({super.key, required this.config});

  static const _megaByte = 1024 * 1024;
  final GameSettingConfig config;
  final SysInfo sysinfo = Platform.isWindows
      ? WindowsSysInfo()
      : Platform.isLinux
          ? LinuxSysInfo()
          : Platform.isMacOS
              ? MacOSSysInfo()
              : throw Exception("Unknown Platform System");

  @override
  Widget body(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final totalMemSize = sysinfo.totalPhyMem / _megaByte;
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
                      text = "${java.versionNumber}: ${java.path}";
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
                                JavaUtil.set
                                    .map(
                                      (e) => RadioListTile(
                                        value: e,
                                        groupValue: java,
                                        title: Text(e.versionNumber),
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
                builder: (_, __, ___) {
                  var jvmArgs = config.jvmArgs;
                  return Text(
                    jvmArgs.isEmpty ? "默认" : jvmArgs,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              onTap: () => showDialog(
                context: Get.context!,
                builder: (_) => HookBuilder(
                  builder: (context) {
                    final controller =
                        useTextEditingController(text: config.jvmArgs);
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
                              data: simpleInputDecorationTheme(context),
                              // TODO: 空判断 格式判断
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
        TitleWidgetGroup(
          "内存",
          children: [
            ValueBuilder<bool?>(
              initialValue: config.autoMemory,
              builder: (value, updater) {
                return ExpansionListTile(
                  isExpaned: !value!,
                  tile: SwitchListTile(
                    title: const Text("游戏内存"),
                    subtitle: const Text("自动分配"),
                    value: value,
                    selected: value,
                    hoverColor: colorWithValue(colors.secondaryContainer, -.05),
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
                              child: StatefulBuilder(
                                builder: (context, setState) => Slider(
                                  inactiveColor: colors.primary.withOpacity(.2),
                                  value: config.maxMemory.toDouble(),
                                  min: 0,
                                  max: totalMemSize,
                                  label: config.maxMemory.toString(),
                                  onChanged: (value) => setState(
                                    () => config.maxMemory = value.toInt(),
                                  ),
                                  onChangeEnd: (value) => setState(
                                    () => config.maxMemory = value.toInt(),
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
                        child: ValueListenableBuilder(
                          valueListenable: config.maxMemoryNotifier,
                          builder: (_, maxMemory, __) => _MemoryAllocationBar(
                            totalMemSize,
                            sysinfo.freePhyMem / _megaByte,
                            config.maxMemory.toDouble(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        TitleWidgetGroup(
          "游戏",
          children: [
            ValueBuilder<bool?>(
              initialValue: config.fullScreen,
              builder: (value, updater) => ExpansionListTile(
                isExpaned: !value!,
                tile: SwitchListTile(
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
                      data: simpleInputDecorationTheme(context),
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
                  data: simpleInputDecorationTheme(context),
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
                  data: simpleInputDecorationTheme(context),
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

class _MemoryAllocationBar extends StatelessWidget {
  const _MemoryAllocationBar(
      this.totalMemSize, this.freeMemSize, this.allocationMemSize);

  final double totalMemSize;
  final double freeMemSize;
  final double allocationMemSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final allocationMemPercent = allocationMemSize / totalMemSize;
    final usedMemSize = totalMemSize - freeMemSize;
    final usedPercent = usedMemSize / totalMemSize;
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
                "使用中内存：${_truncateToDecimalPlaces(usedMemSize / 1024, 1)} / ${_truncateToDecimalPlaces(totalMemSize / 1024, 1)} GB"),
            const Spacer(),
            Text(
                "游戏分配：${_truncateToDecimalPlaces(allocationMemSize / 1024, 1)} GB ${allocationMemSize > freeMemSize ? "(${_truncateToDecimalPlaces(freeMemSize / 1024, 1)} GB 可用)" : ""}"),
          ],
        ),
      ],
    );
  }
}

double _truncateToDecimalPlaces(num value, int fractionalDigits) =>
    (value * pow(10, fractionalDigits)).truncate() / pow(10, fractionalDigits);
