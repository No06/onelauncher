part of 'app.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

void routePop<T extends Object?>({BuildContext? context, T? result}) =>
    Navigator.of(context ?? rootNavigatorKey.currentContext!).pop<T>(result);

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
                _SharedAxisPage(key: state.pageKey, child: const AccountPage()),
          ),
          GoRoute(
            path: '/play',
            pageBuilder: (context, state) => _SharedAxisPage(
              key: state.pageKey,
              child: const GameLibraryPage(),
            ),
          ),
          GoRoute(
            path: '/appearance',
            pageBuilder: (context, state) => _SharedAxisPage(
              key: state.pageKey,
              child: const AppearancePage(),
            ),
          ),
          GoRoute(
            path: '/setting',
            pageBuilder: (context, state) =>
                _SharedAxisPage(key: state.pageKey, child: const SettingPage()),
          ),
        ],
      ),
    ],
  );
});

class _RouteInformationNotifier extends ChangeNotifier {
  _RouteInformationNotifier(this.routeInformationProvider) {
    routeInformationProvider.addListener(notifyListeners);
  }
  final RouteInformationProvider routeInformationProvider;

  @override
  void dispose() {
    routeInformationProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

final _routeInformationNotifierProvider =
    ChangeNotifierProvider<_RouteInformationNotifier>((ref) {
  final goRouter = ref.watch(_routerProvider);
  return _RouteInformationNotifier(goRouter.routeInformationProvider);
});

class _SharedAxisPage<T> extends Page<T> {
  const _SharedAxisPage({required this.child, super.key});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
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
        const begin = Offset(0, 0.1);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
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
