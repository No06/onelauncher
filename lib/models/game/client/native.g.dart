// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Natives _$NativesFromJson(Map<String, dynamic> json) => Natives(
      $enumDecodeNullable(_$NativeEnumMap, json['linux']),
      $enumDecodeNullable(_$NativeEnumMap, json['osx']),
      $enumDecodeNullable(_$NativeEnumMap, json['windows']),
    );

Map<String, dynamic> _$NativesToJson(Natives instance) => <String, dynamic>{
      'linux': _$NativeEnumMap[instance.linux],
      'osx': _$NativeEnumMap[instance.osx],
      'windows': _$NativeEnumMap[instance.windows],
    };

const _$NativeEnumMap = {
  Native.osx: 'osx',
  Native.linux: 'linux',
  Native.windows: 'windows',
};
