import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'skin.g.dart';

@JsonSerializable(includeIfNull: false, createFactory: false)
abstract class Skin {
  const Skin();

  TextureModel get variant;

  Future<Uint8List> u8l();

  Future<Uint8List> drawAvatar() async {
    final source = decodePng(await u8l());
    final wratio = source!.width ~/ 64;
    final lratio =
        (source.height == source.width) ? wratio : source.height ~/ 32;
    late final Image face;
    late final Image hair;
    await Future.wait([
      Future(() => face = copyResize(
          copyCrop(source, x: 8 * wratio, y: 8 * lratio, width: 8, height: 8),
          width: 64,
          height: 64)),
      Future(() => hair = copyResize(
          copyCrop(source, x: 40 * wratio, y: 8 * lratio, width: 8, height: 8),
          width: 72,
          height: 72)),
    ]);
    final head = Image(width: 72, height: 72, numChannels: 4);
    await Future.wait([
      Future(() => compositeImage(head, face, center: true)),
      Future(() => compositeImage(head, hair, center: true)),
    ]);
    return encodePng(head, singleFrame: true, filter: PngFilter.none);
  }

  JsonMap toJson() => _$SkinToJson(this);
}

@JsonEnum()
enum TextureModel {
  @JsonValue('CLASSIC')
  classic('CLASSIC'),
  @JsonValue('SLIM')
  slim('SLIM');

  const TextureModel(this.textureModel);
  final String textureModel;
}
