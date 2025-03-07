import 'package:json_annotation/json_annotation.dart';

/// [JsonKey] with `includeFromJson` and `includeToJson` set to `true`.
class JsonKeyInclude extends JsonKey {
  const JsonKeyInclude() : super(includeFromJson: true, includeToJson: true);
}
