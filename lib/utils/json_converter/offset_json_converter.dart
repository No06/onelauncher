import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

class OffsetJsonConverter extends JsonConverter<Offset, JsonMap> {
  const OffsetJsonConverter();

  @override
  Offset fromJson(JsonMap json) {
    return Offset(json['dx'] as double, json['dy'] as double);
  }

  @override
  JsonMap toJson(Offset object) {
    return {
      'dx': object.dx,
      'dy': object.dy,
    };
  }
}
