import 'package:flutter/material.dart';
import 'package:one_launcher/app.dart';

class SimpleMaterialAppPage extends StatelessWidget {
  const SimpleMaterialAppPage({
    super.key,
    this.title,
    this.body,
    this.leadOnPressed,
  });

  final Widget? title;
  final Widget? body;
  final VoidCallback? leadOnPressed;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      body: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: title,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            padding: const EdgeInsets.all(16),
            onPressed: leadOnPressed,
          ),
        ),
        body: body,
      ),
    );
  }
}
