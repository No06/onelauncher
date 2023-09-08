import 'package:json_annotation/json_annotation.dart';

part 'librarie.g.dart';

@JsonSerializable()
class Librarie {
  Librarie({required this.name});

  final String name;

  factory Librarie.fromJson(Map<String, dynamic> json) =>
      _$LibrarieFromJson(json);
}
