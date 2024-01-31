import 'package:animations/animations.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_launcher/models/json_map.dart';

import 'account_page/account_page.dart';
import 'game_library_page/game_library_page.dart';
import 'appearance_page.dart';
import 'setting_page/setting_page.dart';

const _kDefaultRoutePath = "/home";
final _currentRoutePath = _kDefaultRoutePath.obs;

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final routes = <String, JsonMap>{
    "/account": {
      "name": "账户",
      "icon": Icons.people_outline,
      "selectedIcon": Icons.people
    },
    "/home": {
      "name": "开始游戏",
      "icon": Icons.sports_esports_outlined,
      "selectedIcon": Icons.sports_esports
    },
    "/appearance": {
      "name": "外观",
      "icon": Icons.palette_outlined,
      "selectedIcon": Icons.palette
    },
    "/setting": {
      "name": "设置",
      "icon": Icons.settings_outlined,
      "selectedIcon": Icons.settings
    }
  };

  @override
  Widget build(BuildContext context) {
    return AppPage(
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                _Navigation(routes: routes),
                const VerticalDivider(width: 1),
                _NavigationView(routes: routes),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.name,
    required this.icon,
    required this.selectedIcon,
    this.elevation = 0.0,
    this.isSelected = false,
    this.onTap,
  });

  final String name;
  final Icon icon;
  final Icon selectedIcon;
  final bool isSelected;
  final double elevation;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final seletedColor = colors.primary;
    return AnimatedContainer(
      height: 54,
      duration: Duration(milliseconds: isSelected ? 200 : 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: kDefaultBorderRadius,
        color: isSelected ? seletedColor : seletedColor.withOpacity(0),
        boxShadow: kElevationToShadow[elevation.toInt()],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: seletedColor.withOpacity(.5),
          onTap: isSelected ? () {} : onTap,
          child: Row(
            children: [
              const SizedBox(width: 15),
              isSelected ? selectedIcon : icon,
              const SizedBox(width: 8),
              Text(
                name,
                style: theme.textTheme.labelLarge!.copyWith(
                  color: isSelected ? colors.onPrimary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.routes});

  final Map<String, Map> routes;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.onPrimary;
    return Container(
      width: 200,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        children: [
          for (final route in routes.entries)
            Obx(() {
              final routePath = route.key;
              final isSelected = routePath == _currentRoutePath.value;
              final name = route.value["name"];
              final icon = Icon(route.value["icon"]);
              final selectedIcon =
                  Icon(route.value["selectedIcon"], color: selectedColor);
              void onTap() {
                _currentRoutePath(route.key);
                Get.offNamed(id: 1, route.key);
              }

              return _NavigationButton(
                name: name,
                icon: icon,
                selectedIcon: selectedIcon,
                elevation: isSelected ? 3 : 0,
                isSelected: isSelected,
                onTap: onTap,
              );
            })
        ]
          ..insert(routes.length - 1, const Spacer())
          ..insert(1, const SizedBox(height: 10)),
      ),
    );
  }
}

class _NavigationView extends StatelessWidget {
  const _NavigationView({required this.routes});

  final Map<String, Map> routes;
  static final globalKey = Get.nestedKey(1);

  Route createRoute(final Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          SharedAxisTransition(
        transitionType: SharedAxisTransitionType.vertical,
        fillColor: const Color.fromRGBO(0, 0, 0, 0),
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: widget,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: Navigator(
          key: globalKey,
          initialRoute: _kDefaultRoutePath,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/account':
                return createRoute(AccountPage(
                  pageName: routes['/account']!['name'],
                ));
              case '/home':
                return createRoute(GameLibraryPage(
                  pageName: routes['/home']!['name'],
                ));
              case '/appearance':
                return createRoute(AppearancePage(
                  pageName: routes['/appearance']!['name'],
                ));
              case '/setting':
                return createRoute(SettingPage(
                  pageName: routes['/setting']!['name'],
                ));
            }
            return null;
          },
        ),
      ),
    );
  }
}
