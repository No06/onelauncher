import 'package:flutter/material.dart';

import '../theme.dart';

ThemeData simpleInputDecorationTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      border: OutlineInputBorder(borderRadius: kBorderRadius),
      enabledBorder: OutlineInputBorder(
        borderRadius: kBorderRadius,
        borderSide: const BorderSide(color: Colors.grey),
      ),
    ),
  );
}

class TitleTextFiled extends StatelessWidget {
  const TitleTextFiled({
    super.key,
    this.titleWidth,
    required this.titleText,
    required this.textField,
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
        )
      ],
    );
  }
}
