import 'dart:developer';

const white = "\u001b[37m";
const red = "\u001b[31m";
const green = "\u001b[32m";
const yellow = "\u001b[33m";
const blue = "\u001b[34m";
const magenta = "\u001b[35m";
const cyan = "\u001b[36m";
const reset = "\u001b[0m";

void _print(String colorStr, String message, {String? title}) {
  log("$colorStr$message", name: title ?? '');
}

void debugPrintInfo(String message, {String? title}) =>
    _print(white, message, title: title);

void debugPrintError(String message, {String? title}) =>
    _print(red, message, title: title);

void debugPrint(String message, {String? title, String? contentColor}) =>
    _print(contentColor ?? white, message, title: title);

extension PrintExtension on Object? {
  void printInfo([String? title]) => debugPrintInfo(toString(), title: title);
  void printError([String? title]) => debugPrintError(toString(), title: title);
  void print({String? title, String? contentColor}) =>
      debugPrint(toString(), title: title, contentColor: contentColor);
}
