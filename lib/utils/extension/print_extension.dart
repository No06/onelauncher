import 'dart:developer';

const white = "\u001b[37m";
const red = "\u001b[31m";

extension PrintExtension on Object {
  void _print(String colorStr, [String? title]) {
    title = title == null ? "" : "$title: ";
    log("$colorStr$title${toString()}");
  }

  void printInfo([String? title]) => _print(white, title);

  void printError([String? title]) => _print(red, title);
}
