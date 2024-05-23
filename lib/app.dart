import 'dart:io';

import 'package:animations/animations.dart';
import 'package:go_router/go_router.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:one_launcher/pages/account_page/account_page.dart';
import 'package:one_launcher/pages/appearance_page.dart';
import 'package:one_launcher/pages/game_library_page/game_library_page.dart';
import 'package:one_launcher/pages/setting_page/setting_page.dart';
import 'package:one_launcher/widgets/window_caption.dart';
import 'package:window_manager/window_manager.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
BuildContext? get rootContext => rootNavigatorKey.currentContext;
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class SharedAxisPage extends Page {
  const SharedAxisPage({required this.child, super.key});

  final Widget child;

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) =>
          SharedAxisTransition(
        transitionType: SharedAxisTransitionType.vertical,
        fillColor: const Color.fromRGBO(0, 0, 0, 0),
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/play',
    routes: [
      ShellRoute(
        parentNavigatorKey: rootNavigatorKey,
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _MainPage(child: child),
        routes: [
          GoRoute(
            path: '/account',
            pageBuilder: (context, state) =>
                SharedAxisPage(key: state.pageKey, child: const AccountPage()),
          ),
          GoRoute(
            path: '/play',
            pageBuilder: (context, state) => SharedAxisPage(
                key: state.pageKey, child: const GameLibraryPage()),
          ),
          GoRoute(
            path: '/appearance',
            pageBuilder: (context, state) => SharedAxisPage(
                key: state.pageKey, child: const AppearancePage()),
          ),
          GoRoute(
            path: '/setting',
            pageBuilder: (context, state) =>
                SharedAxisPage(key: state.pageKey, child: const SettingPage()),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = AppConfig.instance.theme;
    return ListenableBuilder(
      listenable: theme,
      builder: (context, child) => MaterialApp.router(
        theme: theme.lightTheme(),
        darkTheme: theme.darkTheme(),
        themeMode: theme.mode,
        routerConfig: _router,
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({super.key, this.body, this.background});

  final Widget? body;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (background != null) background!,
        Scaffold(
          backgroundColor: background == null ? null : Colors.transparent,
          // TODO: 为 Linux 或 MacOS 定制窗口栏
          appBar: Platform.isWindows
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(kWindowCaptionHeight),
                  child: MyWindowCaption(),
                )
              : null,
          body: body,
        ),
      ],
    );
  }
}

class _MainPage extends StatelessWidget {
  const _MainPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                const _NavigationBar(),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.routePath,
    required this.title,
    required this.iconData,
    required this.selectedIconData,
  });

  final String routePath;
  final String title;
  final IconData iconData;
  final IconData selectedIconData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final unSelectedColor = theme.scaffoldBackgroundColor;
    final selectedColor = colors.primary;
    final selectedTextColor = colors.onPrimary;
    final unSelectedTextColor = colors.inverseSurface;
    final hoverColor = selectedColor.withOpacity(.15);

    return ValueListenableBuilder(
      valueListenable: GoRouter.of(context).routeInformationProvider,
      builder: (context, info, child) {
        final currentRoutePath = info.uri.path;
        final isSelected = currentRoutePath == routePath;

        tween() => isSelected
            ? ColorTween(begin: unSelectedColor, end: selectedColor)
            : ColorTween(begin: selectedColor, end: unSelectedColor);

        duration() => isSelected ? Durations.short3 : Duration.zero;

        iconData() => isSelected ? selectedIconData : this.iconData;

        return TweenAnimationBuilder(
          tween: tween(),
          duration: duration(),
          builder: (context, color, child) => Material(
            borderRadius: kDefaultBorderRadius,
            color: color,
            animationDuration: duration(),
            elevation: isSelected ? 3 : 0,
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
          child: SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => GoRouter.of(_shellNavigatorKey.currentState!.context)
                  .go(routePath),
              hoverColor: hoverColor,
              splashColor: selectedColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: TweenAnimationBuilder(
                  tween: isSelected
                      ? ColorTween(
                          begin: unSelectedTextColor, end: selectedTextColor)
                      : ColorTween(
                          begin: selectedTextColor, end: unSelectedTextColor),
                  duration: Durations.short3,
                  builder: (context, color, child) => Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        key: const ValueKey("icon"),
                        iconData(),
                        color: color,
                      ),
                      Text(
                        key: ValueKey(title),
                        title,
                        style:
                            theme.textTheme.labelLarge!.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: const Column(children: [
        _NavigationItem(
          routePath: "/account",
          title: "账号",
          iconData: Icons.people_outline,
          selectedIconData: Icons.people,
        ),
        _NavigationItem(
          routePath: "/play",
          title: "开始游戏",
          iconData: Icons.sports_esports_outlined,
          selectedIconData: Icons.sports_esports,
        ),
        _NavigationItem(
          routePath: "/appearance",
          title: "外观",
          iconData: Icons.palette_outlined,
          selectedIconData: Icons.palette,
        ),
        Spacer(),
        _NavigationItem(
          routePath: "/setting",
          title: "设置",
          iconData: Icons.settings_outlined,
          selectedIconData: Icons.settings,
        ),
      ]),
    );
  }
}
