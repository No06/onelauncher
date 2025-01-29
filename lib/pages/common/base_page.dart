import 'package:flutter/material.dart';

abstract class RoutePage extends StatelessWidget {
  const RoutePage({
    required this.pageName, super.key,
    this.actions,
  });

  final String pageName;
  final List<Widget>? actions;

  Widget appbar() => AppBar(
        backgroundColor: Colors.transparent,
        title: Text(pageName),
        actions: actions,
      );
  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Theme(
          data: theme.copyWith(
            appBarTheme: AppBarTheme(
              titleTextStyle: theme.textTheme.headlineSmall!.copyWith(
                fontSize: 28,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          child: appbar(),
        ),
        body(context),
      ],
    );
  }
}
