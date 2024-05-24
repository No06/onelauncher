part of 'game_library_page.dart';

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MyDynMouseScroll(
          builder: (context, controller, physics) => CustomScrollView(
            controller: controller,
            physics: physics,
            slivers: const [_SliverTitle(), _SliverList()],
          ),
        ),
        const Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(32),
            // TODO: 新安装游戏
            // child: FloatingActionButton(
            //   onPressed: () {},
            //   child: const Icon(Icons.download),
            // ),
          ),
        ),
      ],
    );
  }
}

class _SliverTitle extends ConsumerWidget {
  const _SliverTitle();

  final toolbarHeight = 70.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textThemes = Theme.of(context).textTheme;

    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: theme.scaffoldBackgroundColor,
      shadowColor: Colors.black87,
      titleTextStyle: textThemes.bodyMedium,
      toolbarHeight: toolbarHeight,
      title: SizedBox(
        height: toolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buildWidgetsWithDivider(
            [
              SearchBar(
                onChanged: ref.read(_filterStateProvider.notifier).updateName,
                onSubmitted: ref.read(_filterStateProvider.notifier).updateName,
                elevation: const WidgetStatePropertyAll(3),
                hintText: "搜索配置",
                leading: const Icon(Icons.search),
                constraints: const BoxConstraints(
                  minWidth: 120,
                  maxWidth: 220,
                  minHeight: 42,
                ),
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
              // TODO: 按最近游玩排序
              _OptionItem(
                title: "排序方式",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    value: ref.watch(_filterStateProvider).collation,
                    dropdownStyleData:
                        const DropdownStyleData(useRootNavigator: true),
                    items: [
                      for (var item in _GameCollation.values)
                        DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                    ],
                    onChanged: (value) => ref
                        .read(_filterStateProvider.notifier)
                        .updateCollation(value!),
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 35,
                      width: 120,
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      height: 40,
                      selectedMenuItemBuilder: (context, child) => Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
              _OptionItem(
                title: "版本",
                child: Consumer(
                  builder: (context, ref, child) => Row(
                    children: List.generate(_GameType.values.length, (index) {
                      final type = _GameType.values[index];
                      final types = ref.watch(_filterStateProvider).types;
                      final isSelected = types.contains(type);
                      return _GameTypeCheckbox(
                        isSelected: isSelected,
                        label: type.name,
                        type: type,
                        ruleSet: types,
                        onChanged: (value) {
                          ref
                              .read(_filterStateProvider.notifier)
                              .updateTypeWithSelectedValue(type, value!);
                        },
                      );
                    }),
                  ),
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

class _SliverList extends ConsumerWidget {
  const _SliverList();

  final _divider = const Divider(height: 1, indent: 64, endIndent: 32);

  // 比对配置名
  int _compareByName(Game a, Game b) => a.data.id.compareTo(b.data.id);

  // 筛选游戏类型
  bool _typeFilter(Game game, Set<_GameType> types) =>
      types.isEmpty ? true : types.contains(_GameType.fromGame(game));

  // 将 Game 转换为 _GameItem
  List<Widget> _gameListToItems(Iterable<Game> games) => List.generate(
        games.length,
        (i) => _GameItem(games.elementAt(i)),
      );

  List<Widget> _buildItemList(
    List<Game> gameList,
    _GameCollation collation,
    Set<_GameType> types,
  ) {
    var typeFiltedList = gameList.where((game) => _typeFilter(game, types));
    switch (collation) {
      // TODO: 最近游玩排序
      case _GameCollation.recentlyPlayed:
        return _gameListToItems(typeFiltedList);

      case _GameCollation.byName:
        var filtedGameList = typeFiltedList.toList()..sort(_compareByName);
        return _gameListToItems(filtedGameList);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: appConfig.searchGamesOnPaths(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          snapshot.error.printError();
        }
        final gameList = snapshot.data!;
        return Consumer(builder: (context, ref, child) {
          final filterRule = ref.watch(_filterStateProvider);
          return SliverList.list(
            children:
                _buildItemList(gameList, filterRule.collation, filterRule.types)
                    .joinWith(_divider),
          );
        });
      },
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
    super.key,
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
        title: Text(game.data.id),
        subtitle: Text(game.path),
        subtitleTextStyle: textTheme.bodySmall!.copyWith(
          color: colors.outline,
        ),
        trailing: Obx(
          () => Offstage(
            offstage: !isHover.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: FloatingActionButton.extended(
                    shape: const RoundedRectangleBorder(
                      borderRadius: kDefaultBorderRadius,
                    ),
                    backgroundColor: colors.primary,
                    onPressed: () => showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        if (appConfig.selectedAccount == null) {
                          return const WarningDialog(
                            content: Text("先添加一个账号再启动吧"),
                            onlyConfirm: true,
                            onConfirmed: dialogPop,
                          );
                        }
                        return GameStartupDialog(game: game);
                      },
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
                IconButton(
                  onPressed: () {
                    // TODO:Linux、MacOS待检验是否正常可用
                    OpenFile.open(game.path);
                  },
                  icon: const Icon(Icons.folder),
                ),
                // TODO: 更多操作
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ),
        ),
        // TODO: 点击打开游戏配置
        onTap: () {},
      ),
    );
  }
}
