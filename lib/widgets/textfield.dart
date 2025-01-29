import 'package:flutter/material.dart';
import 'package:one_launcher/consts.dart';

ThemeData simpleInputDecorationThemeData(BuildContext context) {
  return Theme.of(context)
      .copyWith(inputDecorationTheme: simpleInputDecorationtheme);
}

const simpleInputDecorationtheme = InputDecorationTheme(
  contentPadding: EdgeInsets.symmetric(horizontal: 10),
  border: OutlineInputBorder(borderRadius: kDefaultBorderRadius),
  enabledBorder: OutlineInputBorder(
    borderRadius: kDefaultBorderRadius,
    borderSide: BorderSide(color: Colors.grey),
  ),
);

class TitleTextFiled extends StatelessWidget {
  const TitleTextFiled({
    required this.titleText, required this.textField, super.key,
    this.titleWidth,
  });

  final double? titleWidth;
  final String titleText;
  final Widget textField;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: titleWidth,
          child: Text(titleText),
        ),
        Expanded(
          child: textField,
        ),
      ],
    );
  }
}
