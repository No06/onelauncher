// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classifiers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Classifiers _$ClassifiersFromJson(Map<String, dynamic> json) => Classifiers(
      linux: json['natives-linux'] == null
          ? null
          : Artifact.fromJson(json['natives-linux'] as Map<String, dynamic>),
      osx: json['natives-osx'] == null
          ? null
          : Artifact.fromJson(json['natives-osx'] as Map<String, dynamic>),
      windows: json['natives-windows'] == null
          ? null
          : Artifact.fromJson(json['natives-windows'] as Map<String, dynamic>),
      windows_32: json['natives-windows-32'] == null
          ? null
          : Artifact.fromJson(
              json['natives-windows-32'] as Map<String, dynamic>),
      windows_64: json['natives-windows-64'] == null
          ? null
          : Artifact.fromJson(
              json['natives-windows-64'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClassifiersToJson(Classifiers instance) =>
    <String, dynamic>{
      'natives-linux': instance.linux,
      'natives-osx': instance.osx,
      'natives-windows': instance.windows,
      'natives-windows-32': instance.windows_32,
      'natives-windows-64': instance.windows_64,
    };
