import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/account/skin/skin.dart';
import 'package:one_launcher/models/json_map.dart';

part 'local_skin.g.dart';

@JsonSerializable(includeIfNull: false)
class LocalSkin extends Skin {
  const LocalSkin({
    this.type = SkinType.steve,
    TextureModel variant = TextureModel.classic,
    this.localSkinPath,
    this.localCapePath,
  }) : _variant = variant;

  final SkinType type;
  final TextureModel _variant;
  final String? localSkinPath;
  final String? localCapePath;

  @override
  TextureModel get variant => _variant;

  @override
  Future<Uint8List> u8l() async {
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

  factory LocalSkin.fromJson(JsonMap json) => _$LocalSkinFromJson(json);
}

@JsonEnum()
enum SkinType {
  steve("steve"),
  alex("alex"),
  localFile("local_file");

  const SkinType(this.type);
  final String type;
}
