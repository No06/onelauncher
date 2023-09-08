import 'dart:math';

import 'package:beacon/consts.dart';
import 'package:beacon/models/app_config.dart';
import 'package:beacon/utils/java_util.dart';
import 'package:beacon/widgets/snackbar.dart';
import 'package:beacon/widgets/values_notifier.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:get/get.dart';
import 'package:beacon/models/theme_config.dart';
import 'package:beacon/utils/file_picker.dart';
import 'package:beacon/widgets/dialog.dart';
import 'package:beacon/widgets/textfield.dart';
import 'package:beacon/widgets/widget_group.dart';

import '../models/game_path_config.dart';
import '/utils/sysinfo.dart';
import '../widgets/route_page.dart';

class SettingPage extends RoutePage {
  const SettingPage({super.key});

  @override
  String routeName() => "设置";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: title(),
        ),
        SizedBox(
          height: 30,
          child: GetBuilder(
            init: _TabController(),
            builder: (c) => TabBar(
              isScrollable: true,
              controller: c.tabController,
              tabs: c.tabs.keys.map((text) => Tab(text: text)).toList(),
            ),
          ),
        ),
        Expanded(
          child: GetBuilder(
            init: _TabController(),
            builder: (c) => TabBarView(
              controller: c.tabController,
              children: c.tabs.values.toList(),
            ),
          ),
        ),
      ],
    );
  }
}

abstract class _SettingBasePage extends StatelessWidget {
  const _SettingBasePage();

  List<Widget> children(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: children(context),
    );
  }
}

class _GlobalGameSettingPage extends StatelessWidget {
  const _GlobalGameSettingPage();

  @override
  Widget build(BuildContext context) {
    final gameSetting = appConfig.gameSetting;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final totalMemSize = SysInfo.totalPhyMem / kMegaByte;
    return ListView(
      padding: const EdgeInsets.all(15),
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
                      child: ValueListenableBuilder(
                        valueListenable: gameSetting.javaNotifier,
                        builder: (_, java, __) => Column(
                          mainAxisSize: MainAxisSize.min,
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
                                leading: const Icon(Icons.expand_more),
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
        // TitleWidgetGroup(
        //   "测试",
        //   children: [
        //     ListTile(
        //       title: Row(
        //         children: [
        //           FilledButton(
        //             onPressed: () =>
        //                 JavaUtil.set.forEach((java) => print(java)),
        //             child: const Text("测试"),
        //           ),
        //           FilledButton(
        //             onPressed: () {
        //               for (final game in GamePath.paths) {
        //                 game.searchOnVersions();
        //               }
        //             },
        //             child: const Text("搜索游戏"),
        //           ),
        //           FilledButton(
        //             onPressed: () {
        //               for (final path in GamePath.paths) {
        //                 print(
        //                     "游戏路径: ${path.path}, 可用游戏: ${path.availableGames}");
        //               }
        //             },
        //             child: const Text("打印搜索到的游戏"),
        //           ),
        //           FilledButton(
        //             onPressed: () => print(appConfig.accounts),
        //             child: const Text("打印存储的账号"),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

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
}

class _LauncherSettingPage extends _SettingBasePage {
  _LauncherSettingPage();
  final formKey = GlobalKey<FormState>();
  final theme = Get.theme;

  @override
  List<Widget> children(context) {
    return [
      TitleWidgetGroup(
        "游戏目录",
        children: [
          ListTile(
            title: const Text("游戏搜索目录"),
            onTap: () => showDialog(
              context: Get.context!,
              builder: (_) => DefaultDialog(
                title: Row(
                  children: [
                    const Text("游戏搜索目录"),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => WarningDialog(
                          content: const Text("你确定要重置游戏目录吗？"),
                          onConfirmed: () {
                            appConfig.resetPaths();
                            dialogPop();
                          },
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                    ),
                    const Spacer(),
                    FloatingActionButton(
                      mini: true,
                      child: const Icon(Icons.add),
                      onPressed: () => showDialog(
                        context: Get.context!,
                        builder: (_) {
                          final name = TextEditingController();
                          final path = TextEditingController();
                          return DefaultDialog(
                            title: const Text("添加游戏搜索目录"),
                            onConfirmed: () {
                              if (formKey.currentState!.validate()) {
                                if (appConfig.paths.add(GamePath(
                                    name: name.text, path: path.text))) {
                                  dialogPop();
                                  Get.showSnackbar(successSnackBar("添加成功！"));
                                } else {
                                  Get.showSnackbar(errorSnackBar("已有重复目录"));
                                }
                              }
                            },
                            onCanceled: dialogPop,
                            confirmText: const Text("添加"),
                            content: SizedBox(
                              width: 450,
                              child: Form(
                                key: formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: name,
                                      maxLength: 20,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '不能为空';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: kBorderRadius),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: kBorderRadius,
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                        labelText: "别名",
                                      ),
                                    ),
                                    const SizedBox(height: 0),
                                    TextFormField(
                                      readOnly: true,
                                      controller: path,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '不能为空';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: "请选择一个目录",
                                        icon: IconButton(
                                          onPressed: () async {
                                            final folder = await folderPicker();
                                            if (folder != null) {
                                              path.text = folder.path;
                                            }
                                          },
                                          icon: const Icon(Icons.folder_open),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                onlyConfirm: true,
                onConfirmed: dialogPop,
                content: SizedBox(
                  width: 500,
                  child: Obx(
                    () => ListView(
                      shrinkWrap: true,
                      children: appConfig.paths
                          .map(
                            (path) => Card(
                              color:
                                  colorWithValue(theme.colorScheme.surface, .1),
                              child: ListTile(
                                title: Text(path.name),
                                subtitle: Text(
                                  path.path,
                                  style: TextStyle(
                                    color: colorWithValue(
                                        theme.colorScheme.onSurface, -.1),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => WarningDialog(
                                      content: const Text("你确定要删除这条数据吗？"),
                                      onConfirmed: () {
                                        appConfig.paths.remove(path);
                                        dialogPop();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}

class _TabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final TabController tabController;
  final tabs = {
    "全局游戏设置": const _GlobalGameSettingPage(),
    "启动器": _LauncherSettingPage(),
  };

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
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
