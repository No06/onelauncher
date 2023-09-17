import 'package:flutter/material.dart';

abstract class RoutePage extends StatelessWidget {
  const RoutePage({super.key, required this.pageName});

  final String pageName;

  PreferredSizeWidget appbar() => AppBar(title: Text(pageName));
  Widget body();

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
        body(),
      ],
    );
  }
}
