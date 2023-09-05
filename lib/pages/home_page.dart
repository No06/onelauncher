import 'package:animations/animations.dart';
import 'package:beacon/consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'account_page.dart';
import 'game_library_page.dart';
import 'appearance_page.dart';
import 'setting_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Navigation(),
        const VerticalDivider(width: 1),
        const _NavigationView(),
      ],
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
              const SizedBox(width: 10),
              isSelected ? selectedIcon : icon,
              const SizedBox(width: 5),
              Text(
                name,
                style: theme.textTheme.titleSmall!.copyWith(
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
      "name": "库",
      "path": "/home",
      "icon": Icons.apps_outlined,
      "selectedIcon": Icons.apps
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
  final index = 1.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Obx(
        () => Column(
          children: [
            ...routes.asMap().entries.map((entry) {
              final item = entry.value;
              final isSelected = index.value == entry.key;
              final selectedColor = Theme.of(context).colorScheme.onPrimary;
              return _NavigationButton(
                name: item["name"],
                icon: Icon(item["icon"]),
                selectedIcon: Icon(item["selectedIcon"], color: selectedColor),
                elevation: isSelected ? 3 : 0,
                isSelected: isSelected,
                onTap: () {
                  Get.offNamed(id: 1, item["path"]);
                  index(entry.key);
                },
              );
            })
          ]..insert(routes.length - 1, const Spacer()),
        ),
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
          initialRoute: '/home',
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
            }
            return null;
          },
        ),
      ),
    );
  }
}
