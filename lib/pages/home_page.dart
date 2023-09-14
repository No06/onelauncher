import 'package:animations/animations.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/pages/game_page.dart';

import 'account_page.dart';
import 'game_library_page.dart';
import 'appearance_page.dart';
import 'setting_page.dart';

const _kDefaultRouteName = "/home";
final _currentRouteName = _kDefaultRouteName.obs;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                _Navigation(),
                const VerticalDivider(width: 1),
                const _NavigationView(),
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
        borderRadius: kBorderRadius,
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
  _Navigation();

  final routes = <Map<String, dynamic>>[
    {
      "name": "用户",
      "path": "/account",
      "icon": Icons.people_outline,
      "selectedIcon": Icons.people
    },
    {
      "name": "开始游戏",
      "path": "/home",
      "icon": Icons.sports_esports_outlined,
      "selectedIcon": Icons.sports_esports
    },
    {
      "name": "外观",
      "path": "/appearance",
      "icon": Icons.palette_outlined,
      "selectedIcon": Icons.palette
    },
    {
      "name": "设置",
      "path": "/setting",
      "icon": Icons.settings_outlined,
      "selectedIcon": Icons.settings
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        children: [
          ...routes.map((route) {
            final routePath = route['path'];
            final selectedColor = Theme.of(context).colorScheme.onPrimary;
            return Obx(() {
              final isSelected = routePath == _currentRouteName.value;
              return _NavigationButton(
                name: route["name"],
                icon: Icon(route["icon"]),
                selectedIcon: Icon(route["selectedIcon"], color: selectedColor),
                elevation: isSelected ? 3 : 0,
                isSelected: isSelected,
                onTap: () {
                  _currentRouteName(route["path"]);
                  Get.offNamed(id: 1, route["path"]);
                },
              );
            });
          })
        ]
          ..insert(routes.length - 1, const Spacer())
          ..insert(1, const SizedBox(height: 10)),
      ),
    );
  }
}

class _NavigationView extends StatelessWidget {
  const _NavigationView();

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
          key: Get.nestedKey(1),
          initialRoute: _kDefaultRouteName,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/account':
                return createRoute(const AccountPage());
              case '/home':
                return createRoute(const GameLibraryPage());
              case '/appearance':
                return createRoute(const AppearancePage());
              case '/setting':
                return createRoute(const SettingPage());
              case '/game':
                return createRoute(GamePage(game: settings.arguments as Game));
            }
            return null;
          },
        ),
      ),
    );
  }
}
