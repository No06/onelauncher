part of 'game_library_page.dart';

class _ConfigurationPage extends StatelessWidget {
  const _ConfigurationPage();

  @override
  Widget build(BuildContext context) {
    final paths = AppConfig.launcherGamePaths;
    final indexes = appConfig.launcherGamePathIndexes;

    return Stack(
      children: [
        MyDynMouseScroll(
          builder: (context, controller, physics) => ObxValue(
            (data) => ListView(
              controller: controller,
              physics: physics,
              children: List<Widget>.generate(paths.length, (index) {
                    final path = paths[index];
                    return ValueBuilder<bool?>(
                      initialValue: indexes.contains(index),
                      onUpdate: (value) => value ?? false
                          ? indexes.add(index)
                          : indexes.remove(index),
                      builder: (value, updater) => SwitchListTile(
                        selected: value!,
                        title: Text(path.name),
                        subtitle: Text(path.path),
                        value: value,
                        onChanged: updater,
                      ),
                    );
                  }) +
                  List.generate(data.length, (index) {
                    final path = data.elementAt(index);
                    return ValueBuilder<bool?>(
                      initialValue: false,
                      builder: (value, updater) => MouseRegion(
                        onEnter: (_) => updater(true),
                        onExit: (_) => updater(false),
                        child: ListTile(
                          title: Text(path.name),
                          subtitle: Text(path.path),
                          onTap: () {},
                          trailing: Offstage(
                            offstage: !value!,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => WarningDialog(
                                    content: const Text("你确定要删除这条数据吗？"),
                                    onConfirmed: () => dialogPop(result: true),
                                  ),
                                );
                                if (result ?? false) data.remove(path);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            appConfig.paths,
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
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (_) => _AddGamePathDialog(),
                    );
                    if (result ?? false) {
                      showSnackbar(successSnackBar("添加成功！"));
                    }
                  },
                ),
                const SizedBox(height: 16),
                IconButton.filledTonal(
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => WarningDialog(
                        content: const Text("你确定要重置游戏目录吗？这将会删除所有添加的条目"),
                        onConfirmed: () => dialogPop(result: true),
                      ),
                    );
                    if (result ?? false) {
                      appConfig.paths.clear();
                    }
                  },
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

class _AddGamePathDialog extends HookWidget {
  _AddGamePathDialog();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final nameTextCtl = useTextEditingController();
    final pathTextCtl = useTextEditingController();
    return DefaultDialog(
      title: const Text("添加游戏目录"),
      onConfirmed: () {
        if (!formKey.currentState!.validate()) return;

        add() => appConfig.paths.add(GamePath(
              name: nameTextCtl.text,
              path: pathTextCtl.text,
            ));

        if (add()) {
          dialogPop(result: true);
        } else {
          showSnackbar(errorSnackBar("已有重复目录"));
        }
      },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '不能为空';
                  }
                  return null;
                },
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
  }
}
