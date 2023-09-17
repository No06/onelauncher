import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:one_launcher/widgets/adap_window_sizedbox.dart';
import 'package:one_launcher/widgets/route_page.dart';

class GameLibraryPage extends RoutePage {
  const GameLibraryPage({super.key, required super.pageName});

  final tabs = const {
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
              _GameSwitcher(),
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

class _GameSwitcher extends StatelessWidget {
  _GameSwitcher();

  final MenuController _controller = MenuController();

  @override
  Widget build(BuildContext context) {
    // TODO: 动画
    return MenuAnchor(
      controller: _controller,
      menuChildren: [
        MenuItemButton(
          child: buildMenuItem(
            icon: const FlutterLogo(size: 36),
            title: "1.20.2rc",
          ),
        ),
      ],
      builder: (context, controller, child) {
        return buildMenuItem(
          icon: const FlutterLogo(size: 36),
          title: "最新版本",
          lable: "1.20.1",
          suffixIcon: const Icon(Icons.expand_more),
          onTap: _controller.isOpen ? _controller.close : _controller.open,
        );
      },
    );
  }

  Widget buildMenuItem({
    required Widget icon,
    required String title,
    String? lable,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
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
                  icon,
                  const SizedBox(width: 5),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title),
                      if (lable != null)
                        Builder(builder: (context) {
                          final style = Theme.of(context).textTheme.bodySmall!;
                          return Text(
                            lable,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: style.color!.withOpacity(.5)),
                          );
                        }),
                    ],
                  ),
                  const Spacer(),
                  if (suffixIcon != null) suffixIcon,
                ],
              ),
            ),
            InkWell(onTap: onTap),
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
