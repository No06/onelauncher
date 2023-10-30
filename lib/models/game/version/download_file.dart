import 'package:json_annotation/json_annotation.dart';

part 'download_file.g.dart';

@JsonSerializable()
class DownloadFile {
  DownloadFile({
    this.id,
    required this.url,
    required this.sha1,
    required this.size,
  });

  final String? id;
  final String url;
  final String sha1;
  final int size;

  factory DownloadFile.fromJson(Map<String, dynamic> json) =>
      _$DownloadFileFromJson(json);
}
