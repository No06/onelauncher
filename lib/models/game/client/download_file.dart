import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'download_file.g.dart';

@JsonSerializable()
class DownloadFile {
  const DownloadFile({
    required this.url, required this.sha1, required this.size, this.id,
  });

  factory DownloadFile.fromJson(JsonMap json) => _$DownloadFileFromJson(json);

  final String? id;
  final String url;
  final String sha1;
  final int size;
  JsonMap toJson() => _$DownloadFileToJson(this);
}
