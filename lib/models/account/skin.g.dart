// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Skin _$SkinFromJson(Map<String, dynamic> json) => Skin(
      type: $enumDecodeNullable(_$SkinTypeEnumMap, json['type']) ??
          SkinType.steve,
      textureModel:
          $enumDecodeNullable(_$TextureModelEnumMap, json['textureModel']) ??
              TextureModel.def,
      localSkinPath: json['localSkinPath'] as String?,
      localCapePath: json['localCapePath'] as String?,
    );

Map<String, dynamic> _$SkinToJson(Skin instance) {
  final val = <String, dynamic>{
    'type': _$SkinTypeEnumMap[instance.type]!,
    'textureModel': _$TextureModelEnumMap[instance.textureModel]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('localSkinPath', instance.localSkinPath);
  writeNotNull('localCapePath', instance.localCapePath);
  return val;
}

const _$SkinTypeEnumMap = {
  SkinType.steve: 'steve',
  SkinType.alex: 'alex',
  SkinType.localFile: 'localFile',
};

const _$TextureModelEnumMap = {
  TextureModel.def: 'def',
  TextureModel.slim: 'slim',
};
