import 'package:flutter/material.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/utils/extension/color_extension.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackbar(
  SnackBar snackBar, {
  BuildContext? context,
}) =>
    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);

SnackBar defaultSnackBar(
  String title, {
  BuildContext? context,
  Color? backgroundColor,
  Color? textColor,
  IconData? iconData,
}) {
  context = context ?? rootScaffoldMessengerContext!;

  final width = MediaQuery.of(context).size.width / 4;
  final colors = Theme.of(context).colorScheme;

  backgroundColor ??= colors.surfaceBright;
  textColor ??= colors.onSurface;

  return SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(iconData, color: textColor),
        ),
        Text(title, style: TextStyle(color: textColor)),
      ],
    ),
    backgroundColor: backgroundColor,
    duration: const Duration(milliseconds: 1500),
    margin: EdgeInsets.symmetric(vertical: 16, horizontal: width),
  );
}

SnackBar successSnackBar(String title, {BuildContext? context}) {
  return defaultSnackBar(
    title,
    context: context,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    iconData: Icons.check,
  );
}

SnackBar warningSnackBar(String title, {BuildContext? context}) {
  final backgroundColor = Colors.orange[300];
  return defaultSnackBar(
    title,
    context: context,
    backgroundColor: backgroundColor,
    textColor: backgroundColor?.withValue(-.8),
    iconData: Icons.warning,
  );
}

SnackBar errorSnackBar(String title, {BuildContext? context}) {
  final colors = Theme.of(context ?? rootScaffoldMessengerContext!).colorScheme;
  return defaultSnackBar(
    title,
    context: context,
    backgroundColor: colors.error,
    textColor: colors.onError,
    iconData: Icons.error_outline,
  );
}
