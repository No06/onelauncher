import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart';

class Skin {
  final SkinType type; //类型
  final TextureModel? textureModel; //模型
  final String? localSkinPath; //皮肤
  final String? localCapePath; //披风

  const Skin(
    this.type, {
    this.textureModel,
    this.localSkinPath,
    this.localCapePath,
  });

  Future<Uint8List?> get u8l async {
    const steve = "assets/images/skins/steve.png";
    const alex = "assets/images/skins/alex.png";
    switch (type) {
      case SkinType.steve:
        return (await rootBundle.load(steve)).buffer.asUint8List();
      case SkinType.alex:
        return (await rootBundle.load(alex)).buffer.asUint8List();
      // TODO: 正版皮肤获取
      case SkinType.online:
        return null;
      case SkinType.custom:
        return File(localSkinPath!).readAsBytesSync();
    }
  }

  static Uint8List drawAvatar(Uint8List u8l) {
    final source = decodePng(u8l);
    final wratio = source!.width ~/ 64;
    final lratio =
        (source.height == source.width) ? wratio : source.height ~/ 32;
    final face = copyResize(
        copyCrop(source, x: 8 * wratio, y: 8 * lratio, width: 8, height: 8),
        width: 64,
        height: 64);
    final hair = copyResize(
        copyCrop(source, x: 40 * wratio, y: 8 * lratio, width: 8, height: 8),
        width: 72,
        height: 72);
    final head = Image(width: 72, height: 72, numChannels: 4);
    head.clear(ColorInt8.rgba(0, 0, 0, 0));
    compositeImage(head, face, center: true);
    compositeImage(head, hair, center: true);
    return encodePng(head);
  }

  static bool isLegal(file) {
    final Image? source = decodePng(file.readAsBytesSync());
    if (source!.width >= 64 &&
        (source.width / source.height == 1 ||
            source.width / source.height == 2) &&
        source.width % source.height == 0 &&
        source.width % 64 == 0) return true;
    return false;
  }
}

enum SkinType {
  steve,
  alex,
  online,
  custom;
}

enum TextureModel {
  def,
  slim;
}
