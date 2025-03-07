// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_skin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnlineSkin _$OnlineSkinFromJson(Map<String, dynamic> json) => OnlineSkin(
      $enumDecode(_$TextureModelEnumMap, json['variant']),
      json['url'] as String,
    );

const _$TextureModelEnumMap = {
  TextureModel.classic: 'CLASSIC',
  TextureModel.slim: 'SLIM',
};
