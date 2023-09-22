import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/app_config.dart';
import 'package:one_launcher/models/game_path_config.dart';
import 'package:one_launcher/utils/build_widgets_with_divider.dart';
import 'package:one_launcher/utils/file_picker.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:one_launcher/widgets/route_page.dart';
import 'package:one_launcher/widgets/snackbar.dart';

class GameLibraryPage extends RoutePage {
  GameLibraryPage({super.key, required super.pageName});

  final tabs = {
    "主页": _HomePage(),
    "配置": _ConfigurationPage(),
  };

  @override
  Widget body() {
    return DefaultTabController(
      length: tabs.length,
      child: Expanded(
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
              child: TabBarView(children: tabs.values.toList()),
            )
          ],
        ),
      ),
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
  _HomePage();

  final List<String> items = const ['最近游玩', '名称'];
  final selectedValue = GameCollation.values.first.obs;
  static const _dropdownButtonFontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [_buildSliverTitle(context), _buildSliverList()],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(32),
            // TODO: 新安装游戏
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.download),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverTitle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textThemes = Theme.of(context).textTheme;
    const toolbarHeight = 70.0;
    return SliverAppBar(
      pinned: true,
      stretch: true,
      scrolledUnderElevation: 5,
      surfaceTintColor: colors.surface,
      shadowColor: Colors.black87,
      titleTextStyle: textThemes.bodyMedium,
      toolbarHeight: toolbarHeight,
      title: SizedBox(
        height: toolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buildWidgetsWithDivider(
            [
              SearchAnchor(
                builder: (context, controller) => const SearchBar(
                  elevation: MaterialStatePropertyAll(3),
                  hintText: "搜索配置",
                  leading: Icon(Icons.search),
                  constraints: BoxConstraints(
                    minWidth: 120.0,
                    maxWidth: 240.0,
                    minHeight: 42.0,
                  ),
                  padding: MaterialStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),
                suggestionsBuilder: (context, controller) => [],
              ),
              // TODO: 按需排序
              _buildTitleWithItem(
                title: "排序方式",
                child: DropdownButtonHideUnderline(
                  child: Builder(builder: (context) {
                    var selectedValue = GameCollation.values.first;
                    return StatefulBuilder(builder: (context, setState) {
                      return DropdownButton2<GameCollation>(
                        value: selectedValue,
                        isExpanded: true,
                        hint: Text(
                          selectedValue.name,
                          style: TextStyle(
                            fontSize: _dropdownButtonFontSize,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items: GameCollation.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: _dropdownButtonFontSize,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (newVal) => setState(() {
                          selectedValue = newVal!;
                        }),
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          height: 35,
                          width: 120,
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: 40,
                          selectedMenuItemBuilder: (context, child) =>
                              Container(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            child: child,
                          ),
                        ),
                      );
                    });
                  }),
                ),
              ),
              _buildTitleWithItem(
                title: "版本",
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCheckboxWithLable(
                      context: context,
                      label: "正式版",
                      value: false,
                      onChanged: (newVal) {},
                    ),
                    _buildCheckboxWithLable(
                      context: context,
                      label: "快照",
                      value: false,
                      onChanged: (newVal) {},
                    ),
                    _buildCheckboxWithLable(
                      context: context,
                      label: "Mod版",
                      value: false,
                      onChanged: (newVal) {},
                    ),
                  ],
                ),
              )
            ],
            const VerticalDivider(width: 32, indent: 16, endIndent: 16),
          ),
        ),
      ),
    );
  }

  // TODO: 优化搜索存储结果
  Widget _buildSliverList() {
    return FutureBuilder(
      future: appConfig.getGamesOnPaths,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Text(snapshot.stackTrace.toString()),
          );
        } else {
          return SliverList.list(
            children: buildWidgetsWithDivider(
              snapshot.data!
                  .map<Widget>(
                    (game) => ListTile(
                      leading: const FlutterLogo(size: 36),
                      title: Text(game.version.id),
                      subtitle: Text(game.path),
                      subtitleTextStyle:
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                      onTap: () {},
                    ),
                  )
                  .toList(),
              const Divider(height: 1, indent: 64, endIndent: 32),
            ),
          );
        }
      },
    );
  }

  Widget _buildTitleWithItem({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(title), const SizedBox(height: 4), child],
    );
  }

  Widget _buildCheckboxWithLable({
    required BuildContext context,
    required String label,
    required bool? value,
    void Function(bool?)? onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            visualDensity: VisualDensity.comfortable,
            side: BorderSide(
              width: 1.2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(height: 1.25),
        ),
      ],
    );
  }
}

enum GameCollation {
  recentlyPlayed(name: "最近游玩"),
  version(name: "版本"),
  byName(name: "名称");

  final String name;
  const GameCollation({required this.name});
}

class _ConfigurationPage extends StatelessWidget {
  _ConfigurationPage();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(
          () => ListView(
            children: appConfig.paths.map((path) {
              return Builder(
                builder: (context) {
                  var isHover = false.obs;
                  return MouseRegion(
                    onHover: (_) => isHover(true),
                    onExit: (_) => isHover(false),
                    child: ListTile(
                      title: Text(path.name),
                      subtitle: Text(path.path),
                      trailing: Obx(() {
                        if (isHover.value) {
                          return IconButton(
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
                          );
                        }
                        return const SizedBox();
                      }),
                      onTap: () {},
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Flex(
              direction: Axis.vertical,
              verticalDirection: VerticalDirection.up,
              children: [
                FloatingActionButton(
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
                            if (appConfig.paths.add(
                                GamePath(name: name.text, path: path.text))) {
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
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
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
                const SizedBox(height: 16),
                IconButton.filledTonal(
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
                  iconSize: 32,
                  icon: const Icon(Icons.refresh),
                  style: const ButtonStyle(
                    elevation: MaterialStatePropertyAll(5),
                    shadowColor: MaterialStatePropertyAll(Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
