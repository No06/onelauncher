import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/account/skin/skin.dart';
import 'package:one_launcher/models/json_map.dart';

part 'online_skin.g.dart';

@JsonSerializable(includeIfNull: false)
class OnlineSkin extends Skin {
  const OnlineSkin(TextureModel variant, this.url) : _variant = variant;

  // String id;
  // String state;
  final TextureModel _variant;
  final String url;
  // String textureKey;

  @override
  TextureModel get variant => _variant;

  @override
  Future<Uint8List> u8l() async {
    final cache = DefaultCacheManager();
    final imageFile = await cache.getSingleFile(url);
    return await imageFile.readAsBytes();
  }

  factory OnlineSkin.fromJson(JsonMap json) => _$OnlineSkinFromJson(json);

  @override
  JsonMap toJson() => _$OnlineSkinToJson(this);
}
