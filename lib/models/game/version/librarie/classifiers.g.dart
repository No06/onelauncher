// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classifiers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Classifiers _$ClassifiersFromJson(Map<String, dynamic> json) => Classifiers(
      linux: Artifact.fromJson(json['linux'] as Map<String, dynamic>),
      osx: Artifact.fromJson(json['osx'] as Map<String, dynamic>),
      windows: Artifact.fromJson(json['windows'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClassifiersToJson(Classifiers instance) =>
    <String, dynamic>{
      'linux': instance.linux,
      'osx': instance.osx,
      'windows': instance.windows,
    };
