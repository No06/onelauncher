import 'package:one_launcher/models/game/data/download_file.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'asset_index.g.dart';

@JsonSerializable()
class AssetIndex extends DownloadFile {
  const AssetIndex(
    this.totalSize, {
    required super.id,
    required super.url,
    required super.sha1,
    required super.size,
  });

  final int totalSize;

  factory AssetIndex.fromJson(JsonMap json) => _$AssetIndexFromJson(json);
}
