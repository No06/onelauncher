import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:json_annotation/json_annotation.dart';

part 'skin.g.dart';

@JsonSerializable(includeIfNull: false)
class Skin {
  Skin({
    this.type = SkinType.steve,
    this.textureModel = TextureModel.def,
    this.localSkinPath,
    this.localCapePath,
  });
  SkinType type;
  TextureModel textureModel;
  String? localSkinPath;
  String? localCapePath;

  Future<Uint8List> get u8l async {
    const steve = "assets/images/skins/steve.png";
    const alex = "assets/images/skins/alex.png";

    late final String? path;
    switch (type) {
      case SkinType.steve:
        path = steve;
      case SkinType.alex:
        path = alex;
      case SkinType.localFile:
        path = localCapePath;
    }
    return (await rootBundle.load(path ?? steve)).buffer.asUint8List();
  }

  Future<Uint8List> drawAvatar() async {
    final source = decodePng(await u8l);
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

  factory Skin.fromJson(Map<String, dynamic> json) => _$SkinFromJson(json);

  Map<String, dynamic> toJson() => _$SkinToJson(this);
}

@JsonEnum()
enum SkinType {
  steve("steve"),
  alex("alex"),
  localFile("local_file");

  const SkinType(this.type);
  final String type;
}

@JsonEnum()
enum TextureModel {
  def("default"),
  slim("slim");

  const TextureModel(this.textureModel);
  final String textureModel;
}
