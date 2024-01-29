part of 'game_library_page.dart';

class _HomePage extends StatelessWidget {
  _HomePage();

  final selectedValue = GameCollation.values.first.obs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DynMouseScroll(
          animationCurve: kMouseScrollAnimationCurve,
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

class _SliverTitle extends StatelessWidget {
  const _SliverTitle();

  final toolbarHeight = 70.0;

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
      toolbarHeight: toolbarHeight,
      title: SizedBox(
        height: toolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buildWidgetsWithDivider(
            [
              SearchBar(
                onChanged: (value) => _filterRule.searchValue = value,
                onSubmitted: (value) => _filterRule.searchValue = value,
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
                    initialValue: _filterRule.collation,
                    onUpdate: (value) {
                      _filterRule.collation = value!;
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
                                style: const TextStyle(fontSize: 14),
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
              _OptionItem(
                title: "版本",
                child: Row(
                  children: () {
                    final list = ["正式版", "快照", "Mod版"];
                    return List.generate(_GameType.values.length, (index) {
                      final type = _GameType.values[index];
                      final types = _filterRule.gameTypes;
                      return ValueBuilder<bool?>(
                        initialValue: types.contains(type),
                        onUpdate: (value) => value ?? false
                            ? types.add(type)
                            : types.remove(type),
                        builder: (value, updater) => _GameTypeCheckbox(
                          isSelected: value,
                          label: list[index],
                          type: type,
                          ruleSet: types,
                          onChanged: updater,
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

class _SliverList extends StatelessWidget {
  const _SliverList();

  static int _compare(Game a, Game b) => a.version.id.compareTo(b.version.id);
  static const _divider = Divider(height: 1, indent: 64, endIndent: 32);

  bool _where(Game game) => _filterRule.gameTypes.isEmpty
      ? true
      : _filterRule.gameTypes.contains(_GameType.fromGame(game));

  List<Widget> _buildGameItems(List<Game> gameList) {
    switch (_filterRule.collation) {
      // TODO: 最近游玩排序
      case GameCollation.recentlyPlayed:
        return [for (final game in gameList.where(_where)) _GameItem(game)];
      case GameCollation.byName:
        return [
          for (final game
              in gameList.where(_where).toList(growable: false)..sort(_compare))
            _GameItem(game)
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: appConfig.gamesOnPaths,
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
            listenable: _filterRule,
            builder: (context, child) {
              final gameList = snapshot.data!.toList();
              return SliverList.list(
                children: buildWidgetsWithDivider(
                  _buildGameItems(gameList),
                  _divider,
                ),
              );
            },
          );
        }
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
                      borderRadius: kDefaultBorderRadius,
                    ),
                    backgroundColor: colors.primary,
                    onPressed: () => showDialog(
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
        // TODO: 点击打开游戏配置
        onTap: () {},
      ),
    );
  }
}
