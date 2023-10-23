import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nil/nil.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/app_config.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game_path_config.dart';
import 'package:one_launcher/pages/game_startup_page.dart';
import 'package:one_launcher/widgets/build_widgets_with_divider.dart';
import 'package:one_launcher/utils/file_picker.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:one_launcher/widgets/route_page.dart';
import 'package:one_launcher/widgets/snackbar.dart';

const _kGameCollationStgKey = "gameCollation";
const _kGameSortTypesStgKey = "gameSortTypes";

class GameLibraryPage extends RoutePage {
  GameLibraryPage({super.key, required super.pageName});

  final tabs = {
    "主页": _HomePage(),
    "配置": _ConfigurationPage(),
  };

  @override
  Widget body(BuildContext context) {
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

class _HomePage extends StatelessWidget {
  _HomePage();

  final selectedValue = GameCollation.values.first.obs;
  final box = GetStorage();
  late final filterRule = _FilterRule(
    collation: GameCollation.fromInt(box.read<int>(_kGameCollationStgKey)),
    types: box
        .read<List>(_kGameSortTypesStgKey)
        ?.map((e) => _GameType.values[e])
        .toSet(),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _SliverTitle(filterRule: filterRule),
            _SliverList(filterRule: filterRule),
          ],
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
}

class _FilterRule extends ChangeNotifier {
  _FilterRule({
    String name = "",
    GameCollation collation = GameCollation.recentlyPlayed,
    Set<_GameType>? types,
  })  : _searchName = ValueNotifier(name),
        _collation = ValueNotifier(collation),
        _types = (types ?? {}).obs {
    _searchName.addListener(notifyListeners);
    _collation.addListener(notifyListeners);
    ever(_types, (_) => notifyListeners());
  }

  final ValueNotifier<String> _searchName;
  final ValueNotifier<GameCollation> _collation;
  final RxSet<_GameType> _types;

  set searchName(String newVal) => _searchName.value = newVal;
  String get searchName => _searchName.value;

  set collation(GameCollation newVal) => _collation.value = newVal;
  GameCollation get collation => _collation.value;

  RxSet<_GameType> get types => _types;
}

enum _GameType {
  release,
  snapshot,
  mod,
}

class _SliverTitle extends StatelessWidget {
  _SliverTitle({required this.filterRule});

  static const _dropdownButtonFontSize = 14.0;
  static const _toolbarHeight = 70.0;

  final _FilterRule filterRule;
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textThemes = Theme.of(context).textTheme;
    return SliverAppBar(
      pinned: true,
      stretch: true,
      scrolledUnderElevation: 5,
      surfaceTintColor: colors.surface,
      shadowColor: Colors.black87,
      titleTextStyle: textThemes.bodyMedium,
      toolbarHeight: _toolbarHeight,
      title: SizedBox(
        height: _toolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buildWidgetsWithDivider(
            [
              SearchBar(
                onChanged: (value) => filterRule.searchName = value,
                onSubmitted: (value) => filterRule.searchName = value,
                elevation: const MaterialStatePropertyAll(3),
                hintText: "搜索配置",
                leading: const Icon(Icons.search),
                constraints: const BoxConstraints(
                  minWidth: 120,
                  maxWidth: 220,
                  minHeight: 42,
                ),
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
              // TODO: 按最近游玩排序
              _OptionItem(
                title: "排序方式",
                child: DropdownButtonHideUnderline(
                  child: ValueBuilder<GameCollation?>(
                    initialValue: filterRule.collation,
                    onUpdate: (value) {
                      filterRule.collation = value!;
                      box.write(_kGameCollationStgKey, value.index);
                    },
                    builder: (snapshot, updater) {
                      return DropdownButton2<GameCollation>(
                        value: snapshot,
                        dropdownStyleData:
                            const DropdownStyleData(useRootNavigator: true),
                        items: [
                          for (var item in GameCollation.values)
                            DropdownMenuItem(
                              value: item,
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: _dropdownButtonFontSize,
                                ),
                              ),
                            ),
                        ],
                        onChanged: updater,
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
                    },
                  ),
                ),
              ),
              // TODO: 待实现
              _OptionItem(
                title: "版本",
                child: Row(
                  children: () {
                    final list = ["正式版", "快照", "Mod版"];
                    return List.generate(_GameType.values.length, (index) {
                      final type = _GameType.values[index];
                      final types = filterRule.types;
                      return Obx(
                        () => _GameTypeCheckbox(
                          isSelected: types.contains(type),
                          label: list[index],
                          type: type,
                          ruleSet: types,
                          onChanged: (value) {
                            if (value ?? false) {
                              types.add(type);
                              box.write(_kGameSortTypesStgKey,
                                  types.map((e) => e.index).toList());
                            } else {
                              types.remove(type);
                              box.write(_kGameSortTypesStgKey,
                                  types.map((e) => e.index).toList());
                            }
                          },
                        ),
                      );
                    });
                  }(),
                ),
              )
            ],
            const VerticalDivider(width: 32, indent: 16, endIndent: 16),
          ),
        ),
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  const _OptionItem({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _GameTypeCheckbox extends StatelessWidget {
  const _GameTypeCheckbox({
    required this.label,
    required this.type,
    required this.ruleSet,
    this.isSelected,
    this.onChanged,
  });

  final String label;
  final _GameType type;
  final Set<_GameType> ruleSet;
  final bool? isSelected;
  final void Function(bool? value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          if (onChanged != null) {
            onChanged!(isSelected == null ? null : !isSelected!);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: isSelected,
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
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

enum GameCollation {
  recentlyPlayed(name: "最近游玩"),
  byName(name: "名称");

  final String name;
  const GameCollation({required this.name});

  factory GameCollation.fromInt(int? x) => GameCollation.values[x ?? 0];
}

class _SliverList extends StatelessWidget {
  const _SliverList({required this.filterRule});

  final _FilterRule filterRule;

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              snapshot.stackTrace.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          return ListenableBuilder(
            listenable: filterRule,
            builder: (_, __) {
              return SliverList.list(
                children: buildWidgetsWithDivider(
                  () {
                    var data = snapshot.data!.toList();
                    switch (filterRule._collation.value) {
                      case GameCollation.recentlyPlayed:
                        // TODO: 最近游玩排序
                        return data
                            .map<Widget>((game) => _GameItem(game))
                            .toList();
                      case GameCollation.byName:
                        compare(Game a, Game b) =>
                            a.version.id.compareTo(b.version.id);
                        return <Widget>[
                          for (var game in (data..sort(compare)))
                            _GameItem(game)
                        ];
                    }
                  }(),
                  const Divider(height: 1, indent: 64, endIndent: 32),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class _GameItem extends StatelessWidget {
  const _GameItem(this.game);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    final isHover = false.obs;
    return MouseRegion(
      onEnter: (_) => isHover(true),
      onExit: (_) => isHover(false),
      child: ListTile(
        leading: const FlutterLogo(size: 36),
        title: Text(game.version.id),
        subtitle: Text(game.path),
        subtitleTextStyle: textTheme.bodySmall!.copyWith(
          color: colors.outline,
        ),
        trailing: Obx(() {
          if (isHover.value) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: FloatingActionButton.extended(
                    shape: RoundedRectangleBorder(
                      borderRadius: kBorderRadius,
                    ),
                    backgroundColor: colors.primary,
                    onPressed: () => Navigator.push(
                      Get.context!,
                      MaterialPageRoute(
                        builder: (context) => GameStartupPage(game: game),
                      ),
                    ),
                    heroTag: null,
                    icon: Icon(
                      Icons.play_arrow,
                      color: colors.onPrimary,
                    ),
                    label: Text(
                      "开始游戏",
                      style: TextStyle(color: colors.onPrimary),
                    ),
                  ),
                ),
                // TODO: 打开游戏目录
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.folder),
                ),
                // TODO: 更多操作
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            );
          }
          return nil;
        }),
        onTap: () {},
      ),
    );
  }
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
                    onEnter: (_) => isHover(true),
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
                        return nil;
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
                    builder: (_) => HookBuilder(
                      builder: (context) {
                        final nameTextCtl = useTextEditingController();
                        final pathTextCtl = useTextEditingController();
                        return DefaultDialog(
                          title: const Text("添加游戏目录"),
                          onConfirmed: () {
                            if (formKey.currentState!.validate()) {
                              if (appConfig.paths.add(GamePath(
                                  name: nameTextCtl.text,
                                  path: pathTextCtl.text))) {
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
                                    controller: nameTextCtl,
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
                                    controller: pathTextCtl,
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
                                            pathTextCtl.text = folder.path;
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
