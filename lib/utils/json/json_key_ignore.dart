import 'package:json_annotation/json_annotation.dart';

final class JsonKeyIgnore extends JsonKey {
  const JsonKeyIgnore() : super(includeFromJson: false, includeToJson: false);
}
