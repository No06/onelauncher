import 'package:flutter/material.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/widgets/dynamic_color.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackbar(
  SnackBar snackBar, {
  BuildContext? context,
}) =>
    ScaffoldMessenger.of(context ?? rootContext!).showSnackBar(snackBar);

SnackBar defaultSnackBar(
  String title, {
  BuildContext? context,
  Color? backgroundColor,
  Color? textColor,
  IconData? iconData,
}) {
  context = context ?? rootContext!;

  final width = MediaQuery.of(context).size.width / 4;
  final colors = Theme.of(context).colorScheme;
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
    backgroundColor: backgroundColor ?? colors.surfaceBright,
    duration: const Duration(milliseconds: 1500),
    margin: EdgeInsets.symmetric(vertical: 16, horizontal: width),
  );
}

SnackBar successSnackBar(String title, {BuildContext? context}) {
  return defaultSnackBar(
    title,
    context: context,
    backgroundColor: Colors.green,
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
  final colors = Theme.of(context ?? rootContext!).colorScheme;
  return defaultSnackBar(
    title,
    context: context,
    backgroundColor: colors.error,
    textColor: colors.onError,
    iconData: Icons.error_outline,
  );
}
