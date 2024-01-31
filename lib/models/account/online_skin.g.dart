// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_skin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnlineSkin _$OnlineSkinFromJson(Map<String, dynamic> json) => OnlineSkin(
      $enumDecode(_$TextureModelEnumMap, json['variant']),
      json['url'] as String,
    );

Map<String, dynamic> _$OnlineSkinToJson(OnlineSkin instance) =>
    <String, dynamic>{
      'url': instance.url,
      'variant': _$TextureModelEnumMap[instance.variant]!,
    };

const _$TextureModelEnumMap = {
  TextureModel.classic: 'CLASSIC',
  TextureModel.slim: 'SLIM',
};
