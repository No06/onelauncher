import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'download_file.g.dart';

@JsonSerializable()
class DownloadFile {
  const DownloadFile({
    this.id,
    required this.url,
    required this.sha1,
    required this.size,
  });

  final String? id;
  final String url;
  final String sha1;
  final int size;

  factory DownloadFile.fromJson(JsonMap json) => _$DownloadFileFromJson(json);
  JsonMap toJson() => _$DownloadFileToJson(this);
}
