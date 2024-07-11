import 'dart:developer';

const white = "\u001b[37m";
const red = "\u001b[31m";

void _print(String colorStr, String message, {String? title}) {
  title = title == null ? "" : "$title: ";
  log("$colorStr$title$message");
}

void debugPrintInfo(String message, {String? title}) =>
    _print(white, message, title: title);

void debugPrintError(String message, {String? title}) =>
    _print(red, message, title: title);

extension PrintExtension on Object? {
  void printInfo([String? title]) => debugPrintInfo(toString(), title: title);
  void printError([String? title]) => debugPrintError(toString(), title: title);
}
