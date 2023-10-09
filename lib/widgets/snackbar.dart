import 'package:flutter/material.dart';
import 'package:get/get.dart';

GetSnackBar defaultSnackBar(String title, {Color? borderColor, Widget? icon}) {
  final colors = Get.theme.colorScheme;
  // FIXME: 阴影会影响到边框
  return GetSnackBar(
    messageText: Text(title, style: TextStyle(color: colors.onSurface)),
    backgroundColor: colors.surface,
    snackStyle: SnackStyle.FLOATING,
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(milliseconds: 1500),
    margin: const EdgeInsets.only(bottom: 10),
    maxWidth: Get.width * 0.5,
    borderColor: borderColor,
    borderRadius: 12.5,
    boxShadows: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 5,
        offset: Offset(0, 2),
      ),
    ],
    icon: Padding(
      padding: const EdgeInsets.only(left: 5),
      child: icon,
    ),
  );
}

GetSnackBar successSnackBar(String title) {
  return defaultSnackBar(
    title,
    borderColor: Colors.lightGreen,
    icon: const Icon(Icons.check),
  );
}

GetSnackBar warningSnackBar(String title) {
  return defaultSnackBar(
    title,
    borderColor: Colors.orangeAccent,
    icon: const Icon(Icons.warning_amber_rounded),
  );
}

GetSnackBar errorSnackBar(String title) {
  return defaultSnackBar(
    title,
    borderColor: Colors.red,
    icon: const Icon(Icons.error_outline),
  );
}
