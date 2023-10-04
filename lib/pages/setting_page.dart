import 'dart:math';

import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/app_config.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:one_launcher/widgets/route_page.dart';
import 'package:one_launcher/widgets/values_notifier.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:get/get.dart';
import 'package:one_launcher/models/theme_config.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:one_launcher/widgets/textfield.dart';
import 'package:one_launcher/widgets/widget_group.dart';

import '/utils/sysinfo.dart';

class SettingPage extends RoutePage {
  const SettingPage({super.key, required super.pageName});

  final tabs = const {
    "全局游戏设置": _GlobalGameSettingPage(),
    "启动器": _LauncherSettingPage(),
  };

  @override
  Widget body(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: tabs.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 35,
              child: TabBar(
                isScrollable: true,
                tabs: tabs.keys.map((text) => Tab(text: text)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: tabs.values.toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class _SettingBasePage extends StatelessWidget {
  const _SettingBasePage();

  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [body(context)],
    );
  }
}

class _GlobalGameSettingPage extends _SettingBasePage {
  const _GlobalGameSettingPage();

  Widget resolutionTextField(
    int value, {
    void Function(String value)? onSubmitted,
  }) {
    final controller = TextEditingController(text: value.toString());
    final focusNode = FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus && onSubmitted != null) {
        onSubmitted(controller.text);
      }
      return;
    });
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      maxLength: 4,
      decoration: const InputDecoration(
        counterText: "",
      ),
      onSubmitted: onSubmitted,
    );
  }

  Widget textField(
    String text, {
    void Function(String value)? onSubmitted,
    void Function(String)? onChanged,
  }) {
    final controller = TextEditingController(text: text);
    final focusNode = FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus && onSubmitted != null) {
        onSubmitted(controller.text);
      }
      return;
    });
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }

  @override
  Widget body(BuildContext context) {
    final gameSetting = appConfig.gameSetting;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final totalMemSize = SysInfo.totalPhyMem / kMegaByte;
    return Column(
      children: [
        TitleWidgetGroup(
          "Java",
          children: [
            ListTile(
              title: const Text("Java路径"),
              subtitle: () {
                return ValueListenableBuilder(
                  valueListenable: gameSetting.javaNotifier,
                  builder: (_, java, __) {
                    String text;
                    var java = gameSetting.java;
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
                      borderRadius: kBorderRadius,
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        child: ValueListenableBuilder(
                          valueListenable: gameSetting.javaNotifier,
                          builder: (_, java, __) => Column(
                            children: [
                                  RadioListTile(
                                    value: null,
                                    groupValue: java,
                                    title: const Text("自动选择最佳版本"),
                                    onChanged: (value) =>
                                        gameSetting.java = value,
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
                                            gameSetting.java = value,
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
                valueListenable: ValuesNotifier([
                  gameSetting.jvmArgsNotifier,
                  gameSetting.defaultJvmArgsNotifier,
                ]),
                builder: (_, __, ___) {
                  var defaultJvmArgs = gameSetting.defaultJvmArgs;
                  var jvmArgs = gameSetting.jvmArgs;
                  return Text(
                    defaultJvmArgs
                        ? jvmArgs.isEmpty
                            ? '默认'
                            : '默认 + $jvmArgs'
                        : jvmArgs.isEmpty
                            ? '空'
                            : jvmArgs,
                  );
                },
              ),
              onTap: () {
                final jvmArgsController =
                    TextEditingController(text: gameSetting.jvmArgs);
                showDialog(
                  context: Get.context!,
                  builder: (_) => DefaultDialog(
                    title: const Text("JVM启动参数"),
                    onCanceled: () {
                      dialogPop();
                      jvmArgsController.text = gameSetting.jvmArgs;
                    },
                    onConfirmed: () {
                      dialogPop();
                      gameSetting.jvmArgs = jvmArgsController.text;
                    },
                    // TODO: 判断输入正确
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 400,
                          child: Theme(
                            data: simpleInputDecorationTheme(context),
                            child: TextField(
                              controller: jvmArgsController,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Material(
                          color: Colors.transparent,
                          borderRadius: kBorderRadius,
                          clipBehavior: Clip.antiAlias,
                          child: ObxValue(
                            (p0) => ExpansionListTile(
                              isExpaned: p0.value,
                              tile: ListTile(
                                title: const Text("高级"),
                                onTap: () => p0(!p0.value),
                                leading: Transform.rotate(
                                  angle: p0.value ? pi : 0,
                                  child: const Icon(Icons.expand_more),
                                ),
                              ),
                              expandTile: StatefulBuilder(
                                builder: (context, setState) => SwitchListTile(
                                  title: const Text("默认参数"),
                                  value: gameSetting.defaultJvmArgs,
                                  onChanged: (value) => setState(
                                    () => gameSetting.defaultJvmArgs = value,
                                  ),
                                ),
                              ),
                            ),
                            false.obs,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        TitleWidgetGroup(
          "内存",
          children: [
            ValueBuilder<bool?>(
              initialValue: gameSetting.autoMemory,
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
                      gameSetting.autoMemory = value;
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
                                  value: gameSetting.maxMemory.toDouble(),
                                  min: 0,
                                  max: totalMemSize,
                                  label: gameSetting.maxMemory.toString(),
                                  onChanged: (value) => setState(
                                    () => gameSetting.maxMemory = value.toInt(),
                                  ),
                                  onChangeEnd: (value) => setState(
                                    () => gameSetting.maxMemory = value.toInt(),
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
                          valueListenable: gameSetting.maxMemoryNotifier,
                          builder: (_, maxMemory, __) => _MemoryAllocationBar(
                            totalMemSize,
                            SysInfo.freePhyMem / kMegaByte,
                            gameSetting.maxMemory.toDouble(),
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
              initialValue: gameSetting.fullScreen,
              builder: (value, updater) => ExpansionListTile(
                isExpaned: !value!,
                tile: SwitchListTile(
                  value: value,
                  selected: value,
                  title: const Text("全屏"),
                  onChanged: (value) {
                    gameSetting.fullScreen = value;
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
                            child: resolutionTextField(
                              gameSetting.width,
                              onSubmitted: (value) {
                                gameSetting.width = int.parse(value);
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("X"),
                          ),
                          SizedBox(
                            width: 65,
                            child: resolutionTextField(
                              gameSetting.height,
                              onSubmitted: (value) {
                                gameSetting.height = int.parse(value);
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
              initialValue: gameSetting.log,
              builder: (value, updater) => SwitchListTile(
                value: value!,
                selected: value,
                title: const Text("日志"),
                onChanged: (value) {
                  updater(value);
                  gameSetting.log = value;
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
                    child: textField(
                      gameSetting.args,
                      onSubmitted: (value) {
                        gameSetting.args = value;
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
                    child: textField(
                      gameSetting.serverAddress,
                      onChanged: (value) {
                        gameSetting.serverAddress = value;
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

class _LauncherSettingPage extends _SettingBasePage {
  const _LauncherSettingPage();

  @override
  Widget body(BuildContext context) {
    return const SizedBox();
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
            borderRadius: kBorderRadius,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(.2),
                    borderRadius: kBorderRadius,
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
