import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogConfirmButton extends StatelessWidget {
  const DialogConfirmButton({super.key, this.onPressed, this.confirmText});

  final void Function()? onPressed;
  final Widget? confirmText;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
        side: MaterialStateProperty.all(BorderSide(
            color: Theme.of(context).colorScheme.primary, width: 1.0)),
      ),
      onPressed: onPressed,
      child: confirmText ?? const Text("确定", style: TextStyle(fontSize: 16)),
    );
  }
}

class DialogCancelButton extends StatelessWidget {
  const DialogCancelButton({super.key, this.onPressed, this.cancelText});

  final void Function()? onPressed;
  final Widget? cancelText;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: cancelText ?? const Text("取消", style: TextStyle(fontSize: 16)),
    );
  }
}

class DefaultDialog extends StatelessWidget {
  const DefaultDialog({
    super.key,
    this.title,
    this.content,
    this.onlyConfirm = false,
    this.onConfirmed,
    this.onCanceled,
    this.confirmText,
    this.cancelText,
  });

  final Widget? title;
  final Widget? content;
  final bool onlyConfirm;
  final void Function()? onConfirmed;
  final void Function()? onCanceled;
  final Widget? confirmText;
  final Widget? cancelText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.headlineSmall;
    return AlertDialog(
      titleTextStyle: textTheme!.copyWith(fontWeight: FontWeight.bold),
      title: title,
      content: content,
      actions: [
        if (!onlyConfirm)
          DialogCancelButton(
            onPressed: onCanceled,
            cancelText: cancelText,
          ),
        DialogConfirmButton(
          onPressed: onConfirmed,
          confirmText: confirmText,
        ),
      ],
    );
  }
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    this.title,
    this.content,
    this.onConfirmed,
  });

  final Widget? title;
  final Widget? content;
  final void Function()? onConfirmed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: Row(children: [
        Icon(
          Icons.error_outline,
          size: 36,
          color: Colors.red[400],
        ),
        const SizedBox(width: 10),
        content ?? const SizedBox(),
      ]),
      actions: [
        DialogConfirmButton(onPressed: onConfirmed),
      ],
    );
  }
}

void dialogPop() {
  Navigator.of(Get.context!).pop();
}
