import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/utils/extension/color_extension.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackbar(
  SnackBar snackBar, {
  BuildContext? context,
}) {
  if (context != null) {
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {
    return rootScaffoldKey.currentState?.showSnackBar(snackBar);
  }
}

SnackBar defaultSnackBar({
  required String title,
  String? content,
  BuildContext? context,
  Color? backgroundColor,
  Color? textColor,
  IconData? iconData,
  Duration? duration,
}) {
  context = context ?? rootScaffoldContext!;
  final colors = Theme.of(context).colorScheme;

  backgroundColor ??= colors.surfaceBright;
  textColor ??= colors.onSurface;

  final horizontalPadding = MediaQuery.of(context).size.width / 4;
  final contentMaxHeight = MediaQuery.of(context).size.height / 4;
  final contentTextStyle = TextStyle(color: textColor);
  final titleTextStyle = Theme.of(context)
      .textTheme
      .titleMedium
      ?.copyWith(color: textColor, fontWeight: FontWeight.w600)
      .useSystemChineseFont();
  final hasContent = content != null;

  return SnackBar(
    behavior: SnackBarBehavior.floating,
    content: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: contentMaxHeight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(iconData, color: textColor),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: hasContent
                      ? const EdgeInsets.only(bottom: 4)
                      : EdgeInsets.zero,
                  child: Text(
                    title,
                    style: hasContent ? titleTextStyle : contentTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasContent)
                  Flexible(child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fontSize =
                          contentTextStyle.fontSize ?? kDefaultFontSize;
                      final maxLines =
                          (constraints.maxHeight / (fontSize * 2)).floor();

                      return Text(
                        content,
                        style: contentTextStyle,
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),),
              ],
            ),
          ),
        ],
      ),
    ),
    backgroundColor: backgroundColor,
    duration: duration ?? const Duration(milliseconds: 1500),
    margin: EdgeInsets.symmetric(vertical: 16, horizontal: horizontalPadding),
  );
}

SnackBar successSnackBar({
  required String title,
  String? content,
  BuildContext? context,
}) {
  return defaultSnackBar(
    title: title,
    content: content,
    context: context,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    iconData: Icons.check,
  );
}

SnackBar warningSnackBar({
  required String title,
  String? content,
  BuildContext? context,
}) {
  final backgroundColor = Colors.orange[300];
  return defaultSnackBar(
    title: title,
    content: content,
    context: context,
    backgroundColor: backgroundColor,
    textColor: backgroundColor?.withValue(-.8),
    iconData: Icons.warning,
  );
}

SnackBar errorSnackBar({
  required String title,
  String? content,
  BuildContext? context,
}) {
  final colors = Theme.of(context ?? rootScaffoldContext!).colorScheme;
  return defaultSnackBar(
    title: title,
    content: content,
    context: context,
    backgroundColor: colors.error,
    textColor: colors.onError,
    iconData: Icons.error_outline,
    duration: const Duration(seconds: 3),
  );
}
