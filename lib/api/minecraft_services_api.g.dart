// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minecraft_services_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      json['id'] as String,
      json['name'] as String,
      (json['skins'] as List<dynamic>)
          .map((e) => OnlineSkin.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'skins': instance.skins,
    };
