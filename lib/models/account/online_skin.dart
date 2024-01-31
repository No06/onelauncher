import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/account/skin.dart';
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
    var r = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));
    return r.data;
  }

  factory OnlineSkin.fromJson(JsonMap json) => _$OnlineSkinFromJson(json);
}
