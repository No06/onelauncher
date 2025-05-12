import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/pages/account_page/account_page.dart';
import 'package:one_launcher/pages/appearance_page.dart';
import 'package:one_launcher/pages/download_page/download_page.dart';
import 'package:one_launcher/pages/game_library_page/game_library_page.dart';
import 'package:one_launcher/pages/setting_page/setting_page.dart';
import 'package:one_launcher/provider/theme_provider.dart';
import 'package:one_launcher/widgets/window_caption.dart';
import 'package:window_manager/window_manager.dart';

part 'router.dart';

final rootScaffoldKey = GlobalKey<ScaffoldMessengerState>();
BuildContext? get rootScaffoldContext => rootScaffoldKey.currentContext;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final router = ref.read(_routerProvider);
    final themeMode = theme.mode;
    final lightTheme = theme.lightTheme;
    final darkTheme = theme.darkTheme;
    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({super.key, this.body, this.background})
      : hasBackground = background != null;

  final Widget? body;
  final Widget? background;
  final bool hasBackground;

  @override
  Widget build(BuildContext context) {
    // TODO: 为 Windows 删除边框，为 Linux 或 MacOS 适配窗口样式
    return VirtualWindowFrame(
      child: Stack(
        children: [
          if (hasBackground) background!,
          Scaffold(
            backgroundColor: hasBackground ? Colors.transparent : null,
            appBar: kHideTitleBar
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(kWindowCaptionHeight),
                    child: MyWindowCaption(),
                  )
                : null,
            body: body,
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final unSelectedColor = theme.scaffoldBackgroundColor;
    final selectedColor = colors.primary;
    final selectedTextColor = colors.onPrimary;
    final unSelectedTextColor = colors.inverseSurface;
    final hoverColor = selectedColor.withValues(alpha: .15);

    final isSelected = ref.watch(
      _routeInformationNotifierProvider.select(
        (state) => state.routeInformationProvider.value.uri.path == routePath,
      ),
    );

    final tween = isSelected
        ? ColorTween(begin: unSelectedColor, end: selectedColor)
        : ColorTween(begin: selectedColor, end: unSelectedColor);

    final textColorTween = isSelected
        ? ColorTween(begin: unSelectedTextColor, end: selectedTextColor)
        : ColorTween(begin: selectedTextColor, end: unSelectedTextColor);

    final duration = isSelected ? Durations.short3 : Duration.zero;

    final iconData = isSelected ? selectedIconData : this.iconData;

    return TweenAnimationBuilder(
      tween: tween,
      duration: duration,
      builder: (context, color, child) => Material(
        borderRadius: kDefaultBorderRadius,
        color: isSelected ? color : Colors.transparent,
        animationDuration: duration,
        elevation: isSelected ? 3 : 0,
        child: child,
      ),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () => GoRouter.of(_shellNavigatorKey.currentState!.context)
              .go(routePath),
          hoverColor: hoverColor,
          splashColor: selectedColor,
          borderRadius: kDefaultBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: TweenAnimationBuilder(
              tween: textColorTween,
              duration: Durations.short3,
              builder: (context, color, child) => Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    key: const ValueKey("icon"),
                    iconData,
                    color: color,
                  ),
                  Text(
                    title,
                    style: theme.textTheme.labelLarge!
                        .copyWith(color: color, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar();

  @override
  Widget build(BuildContext context) {
    const divider = SizedBox(height: 2);
    return const SizedBox(
      width: 200,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            _NavigationItem(
              routePath: "/account",
              title: "账号",
              iconData: Icons.people_outline,
              selectedIconData: Icons.people,
            ),
            divider,
            _NavigationItem(
              routePath: "/play",
              title: "开始游戏",
              iconData: Icons.sports_esports_outlined,
              selectedIconData: Icons.sports_esports,
            ),
            _NavigationItem(
              routePath: "/download",
              title: "下载",
              iconData: Icons.download_outlined,
              selectedIconData: Icons.download,
            ),
            divider,
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
          ],
        ),
      ),
    );
  }
}
