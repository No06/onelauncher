part of 'game_library_page.dart';

class _ConfigurationPage extends StatelessWidget {
  const _ConfigurationPage();

  static final _formKey = GlobalKey<FormState>();
  static final _paths = AppConfig.launcherGamePaths;
  static final _indexes = appConfig.launcherGamePathIndexes;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MyDynMouseScroll(
          builder: (context, controller, physics) => ObxValue(
            (data) => ListView(
              controller: controller,
              physics: physics,
              children: List<Widget>.generate(_paths.length, (index) {
                    final path = _paths[index];
                    return ValueBuilder<bool?>(
                      initialValue: _indexes.contains(index),
                      onUpdate: (value) => value ?? false
                          ? _indexes.add(index)
                          : _indexes.remove(index),
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
                          trailing: value ?? false
                              ? IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => WarningDialog(
                                      content: const Text("你确定要删除这条数据吗？"),
                                      onConfirmed: () {
                                        data.remove(path);
                                        dialogPop();
                                      },
                                    ),
                                  ),
                                )
                              : null,
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
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => HookBuilder(
                      builder: (context) {
                        final nameTextCtl = useTextEditingController();
                        final pathTextCtl = useTextEditingController();
                        return DefaultDialog(
                          title: const Text("添加游戏目录"),
                          onConfirmed: () {
                            if (_formKey.currentState!.validate()) {
                              if (appConfig.paths.add(GamePath(
                                name: nameTextCtl.text,
                                path: pathTextCtl.text,
                              ))) {
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
                              key: _formKey,
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
                                          borderRadius: kDefaultBorderRadius),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: kDefaultBorderRadius,
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
                      content: const Text("你确定要重置游戏目录吗？这将会删除所有添加的条目"),
                      onConfirmed: () {
                        appConfig.paths.clear();
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
