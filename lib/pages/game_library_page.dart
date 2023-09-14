import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_launcher/widgets/adap_window_sizedbox.dart';

import '/utils/file_picker.dart';
import '../widgets/route_page.dart';
import '/widgets/dialog.dart';

class GameLibraryPage extends RoutePage {
  const GameLibraryPage({super.key});

  @override
  String routeName() => "开始游戏";

  @override
  Widget build(BuildContext context) {
    const tabs = {
      "主页": _HomePage(),
      "配置": _ConfigurationPage(),
    };
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: title(),
          ),
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
    );
  }

  Widget toolBar() {
    return SizedBox(
      height: 65,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            const Spacer(),
            ElevatedButton(
              onPressed: () => showDialog(
                context: Get.context!,
                builder: (context) => addGameDialog(),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.add),
                    Text("添加游戏"),
                    SizedBox(width: 7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addGameDialog() {
    final javaDirController = TextEditingController();
    final gameDirController = TextEditingController();

    return AlertDialog(
      title: const Text("添加游戏"),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTextField(
              icon: Icons.file_open,
              label: "Java路径",
              hintText: "java.exe",
              controller: javaDirController,
              onPressed: () async {
                final File? file = await filePicker(['exe']);
                javaDirController.text = file!.path;
              },
            ),
            const SizedBox(height: 10),
            IconTextField(
              icon: Icons.folder_open,
              label: "Minecraft路径",
              hintText: ".minecraft",
              controller: gameDirController,
              onPressed: () async {
                final File? file = await folderPicker();
                gameDirController.text = file!.path;
              },
            ),
          ],
        ),
      ),
      actions: [
        DialogConfirmButton(onPressed: () {}),
        DialogCancelButton(onPressed: () {}),
      ],
    );
  }
}

class IconTextField extends StatelessWidget {
  const IconTextField({
    super.key,
    required this.icon,
    required this.label,
    required this.hintText,
    required this.controller,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final String hintText;
  final TextEditingController controller;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPressed ?? () {},
          icon: Icon(icon),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.5))),
              hintText: hintText,
              label: Text(label),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              AdaptiveWindowSizedBox(
                hScale: 0.6,
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.asset(
                      "assets/images/background/minecraft-java-edition-wallpaper.png",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 0),
        SizedBox(
          height: 55,
          child: Row(
            children: [
              const _GameSwitch(),
              const Spacer(),
              Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.green,
                    brightness: Theme.of(context).brightness,
                  ),
                ).useSystemChineseFont(),
                child: Builder(builder: (context) {
                  final theme = Theme.of(context);
                  final colors = theme.colorScheme;
                  return Material(
                    color: colors.primaryContainer,
                    child: InkWell(
                      splashColor: colors.primary.withOpacity(.1),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow,
                                size: 32,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "开始游戏",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      height: 1,
                                      letterSpacing: 1,
                                      color: colors.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameSwitch extends StatelessWidget {
  const _GameSwitch();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Material(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
              child: Row(
                children: [
                  const FlutterLogo(size: 36),
                  const SizedBox(width: 5),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("最新版本"),
                      Builder(builder: (context) {
                        final style = Theme.of(context).textTheme.bodySmall!;
                        return Text(
                          "1.20.1",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: style.color!.withOpacity(.5)),
                        );
                      }),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
            InkWell(onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _ConfigurationPage extends StatelessWidget {
  const _ConfigurationPage();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
