import 'package:json_annotation/json_annotation.dart';

/// [JsonKey] with `includeFromJson` and `includeToJson` set to `false`.
final class JsonKeyIgnore extends JsonKey {
  const JsonKeyIgnore() : super(includeFromJson: false, includeToJson: false);
}
