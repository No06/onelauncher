import 'package:one_launcher/models/game/version/download_file.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asset_index.g.dart';

@JsonSerializable()
class AssetIndex extends DownloadFile {
  AssetIndex(
    this.totalSize, {
    required super.id,
    required super.url,
    required super.sha1,
    required super.size,
  });

  final int totalSize;

  factory AssetIndex.fromJson(Map<String, dynamic> json) =>
      _$AssetIndexFromJson(json);
}
