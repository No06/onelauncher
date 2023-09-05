import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

abstract class RoutePage extends StatelessWidget {
  const RoutePage({super.key});

  String routeName();

  Widget title() {
    return Text(
      routeName(),
      style: TextStyle(
        fontSize: Theme.of(Get.context!).textTheme.headlineLarge!.fontSize,
      ),
    );
  }
}
