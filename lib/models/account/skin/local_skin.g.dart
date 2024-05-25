// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_skin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalSkin _$LocalSkinFromJson(Map<String, dynamic> json) => LocalSkin(
      type: $enumDecodeNullable(_$SkinTypeEnumMap, json['type']) ??
          SkinType.steve,
      variant: $enumDecodeNullable(_$TextureModelEnumMap, json['variant']) ??
          TextureModel.classic,
      localSkinPath: json['localSkinPath'] as String?,
      localCapePath: json['localCapePath'] as String?,
    );

Map<String, dynamic> _$LocalSkinToJson(LocalSkin instance) {
  final val = <String, dynamic>{
    'type': _$SkinTypeEnumMap[instance.type]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('localSkinPath', instance.localSkinPath);
  writeNotNull('localCapePath', instance.localCapePath);
  val['variant'] = _$TextureModelEnumMap[instance.variant]!;
  return val;
}

const _$SkinTypeEnumMap = {
  SkinType.steve: 'steve',
  SkinType.alex: 'alex',
  SkinType.localFile: 'localFile',
};

const _$TextureModelEnumMap = {
  TextureModel.classic: 'CLASSIC',
  TextureModel.slim: 'SLIM',
};
