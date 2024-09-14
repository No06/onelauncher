import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/account/skin/skin.dart';
import 'package:one_launcher/models/json_map.dart';

part 'local_skin.g.dart';

@JsonSerializable(includeIfNull: false, createToJson: false)
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

  static final steve = _localImgU8l("assets/images/skins/steve.png");
  static final alex = _localImgU8l("assets/images/skins/alex.png");

  @override
  TextureModel get variant => _variant;

  @override
  Future<Uint8List> u8l() async {
    switch (type) {
      case SkinType.steve:
        return steve;
      case SkinType.alex:
        return alex;
      case SkinType.localFile:
        // TODO: 自定义本地皮肤
        throw UnimplementedError();
    }
  }

  factory LocalSkin.fromJson(JsonMap json) => _$LocalSkinFromJson(json);

  @override
  JsonMap toJson() => _$LocalSkinToJson(this);
}

Future<Uint8List> _localImgU8l(String key) => rootBundle.load(key).then(
      (data) => data.buffer.asUint8List(),
    );

@JsonEnum()
enum SkinType {
  steve("steve"),
  alex("alex"),
  localFile("local_file");

  const SkinType(this.type);
  final String type;
}
