import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';

part 'maven_librarie.g.dart';

@JsonSerializable()
class MavenLibrarie extends Librarie {
  MavenLibrarie(String name, this.url)
      : _nameSplit = name.split(":"),
        super(name: name);

  final String url;

  final List<String> _nameSplit;
  late final List<String> _domainSplit = _nameSplit[0].split('.');

  String get domain => _nameSplit[0];
  String get domainSuffix => _domainSplit[0];
  String get domainName => _domainSplit[1];
  String get packageName => _nameSplit[1];
  String get packageVersion => _nameSplit[2];
  String get downloadUrl =>
      "$url/$domainSuffix/$domainName/$packageName/$packageVersion/$packageName-$packageVersion.jar";

  factory MavenLibrarie.fromJson(Map<String, dynamic> json) =>
      _$MavenLibrarieFromJson(json);
}
