import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

class ColorJsonConverter extends JsonConverter<Color, JsonMap> {
  const ColorJsonConverter();

  @override
  Color fromJson(JsonMap json) {
    final a = json['a'] as double;
    final r = json['r'] as double;
    final g = json['g'] as double;
    final b = json['b'] as double;
    return Color.from(alpha: a, red: r, green: g, blue: b);
  }

  @override
  JsonMap toJson(Color object) => {
        'a': object.a,
        'r': object.r,
        'g': object.g,
        'b': object.b,
      };
}
