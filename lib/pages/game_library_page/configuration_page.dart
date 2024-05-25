part of 'game_library_page.dart';

class _ConfigurationPage extends ConsumerWidget {
  const _ConfigurationPage();

  Future<void> _onPressedAddGamePath(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _AddGamePathDialog(),
    );
    if (result ?? false) {
      showSnackbar(successSnackBar("添加成功！"));
    }
  }

  Future<void> _onPressedResetGamePath(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WarningDialog(
        content: const Text("你确定要重置游戏目录吗？这将会删除所有添加的条目"),
        onConfirmed: () => Navigator.of(context).pop(true),
      ),
    );
    if (result ?? false) {
      ref.read(gamePathProvider.notifier).clearPaths();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        const _ConfigurationView(),
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
                  onPressed: () => _onPressedAddGamePath(context),
                ),
                const SizedBox(height: 16),
                IconButton.filledTonal(
                  onPressed: () => _onPressedResetGamePath(context, ref),
                  iconSize: 32,
                  icon: const Icon(Icons.refresh),
                  style: const ButtonStyle(
                    elevation: WidgetStatePropertyAll(5),
                    shadowColor: WidgetStatePropertyAll(Colors.black87),
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

class _ConfigurationView extends StatelessWidget {
  const _ConfigurationView();

  @override
  Widget build(BuildContext context) {
    final launcherGamePaths = GamePathState.launcherGamePaths;

    return MyDynMouseScroll(
      builder: (context, controller, physics) => ListView(
        controller: controller,
        physics: physics,
        children: [
          ...launcherGamePaths
              .map((path) => _LauncherGamePathListTile(path: path)),
          Consumer(builder: (context, ref, child) {
            final addedPaths =
                ref.watch(gamePathProvider.select((state) => state.addedPaths));
            return Column(
              children: [
                ...addedPaths.map((path) => _GamePathListTile(path: path)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _LauncherGamePathListTile extends ConsumerWidget {
  final GamePath path;

  const _LauncherGamePathListTile({required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref
        .watch(gamePathProvider.select((state) => state.paths.contains(path)));
    final notifier = ref.read(gamePathProvider.notifier);

    return SwitchListTile(
      selected: isSelected,
      title: Text(path.name),
      subtitle: Text(path.path),
      value: isSelected,
      onChanged: (value) =>
          value ? notifier.addPath(path) : notifier.removePath(path),
    );
  }
}

class _GamePathListTile extends ConsumerStatefulWidget {
  final GamePath path;

  const _GamePathListTile({required this.path});

  @override
  _HoverListTileState createState() => _HoverListTileState();
}

class _HoverListTileState extends ConsumerState<_GamePathListTile> {
  var isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: ListTile(
        title: Text(widget.path.name),
        subtitle: Text(widget.path.path),
        onTap: () {},
        trailing: Offstage(
          offstage: !isHover,
          child: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => WarningDialog(
                  content: const Text("你确定要删除这条数据吗？"),
                  onConfirmed: () => Navigator.of(context).pop(true),
                ),
              );
              if (result ?? false) {
                ref.read(gamePathProvider.notifier).removePath(widget.path);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _AddGamePathDialog extends HookConsumerWidget {
  _AddGamePathDialog();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameTextCtl = useTextEditingController();
    final pathTextCtl = useTextEditingController();
    return DefaultDialog(
      title: const Text("添加游戏目录"),
      onConfirmed: () => _confirm(nameTextCtl.text, pathTextCtl.text, ref),
      onCanceled: dialogPop,
      confirmText: const Text("添加"),
      content: SizedBox(
        width: 450,
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameTextCtl,
                maxLength: 20,
                validator: FormValidator.noEmpty,
                decoration: const InputDecoration(
                  border:
                      OutlineInputBorder(borderRadius: kDefaultBorderRadius),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: kDefaultBorderRadius,
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelText: "别名",
                ),
              ),
              const SizedBox(height: 0),
              TextFormField(
                readOnly: true,
                controller: pathTextCtl,
                validator: FormValidator.noEmpty,
                decoration: InputDecoration(
                  hintText: "请选择一个目录",
                  icon: IconButton(
                    onPressed: () => _onPressedPickFolder(pathTextCtl),
                    icon: const Icon(Icons.folder_open),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(String name, String path, WidgetRef ref) async {
    if (!formKey.currentState!.validate()) return;

    add() => ref
        .read(gamePathProvider.notifier)
        .addPath(GamePath(name: name, path: path));

    if (add()) {
      dialogPop(result: true);
    } else {
      showSnackbar(warningSnackBar("已有重复目录"));
    }
  }

  Future<void> _onPressedPickFolder(TextEditingController pathTextCtl) async {
    final folder = await folderPicker();
    if (folder != null) {
      pathTextCtl.text = folder.path;
    }
  }
}
