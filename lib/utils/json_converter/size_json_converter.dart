import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

class SizeJsonConverter implements JsonConverter<Size, JsonMap> {
  const SizeJsonConverter();

  @override
  Size fromJson(JsonMap json) {
    return Size(json['width'] as double, json['height'] as double);
  }

  @override
  JsonMap toJson(Size object) {
    return {
      'width': object.width,
      'height': object.height,
    };
  }
}
