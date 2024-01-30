// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'os.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Os _$OsFromJson(Map<String, dynamic> json) => Os(
      name: $enumDecode(_$OsNameEnumMap, json['name']),
    );

Map<String, dynamic> _$OsToJson(Os instance) => <String, dynamic>{
      'name': _$OsNameEnumMap[instance.name]!,
    };

const _$OsNameEnumMap = {
  OsName.windows: 'windows',
  OsName.linux: 'linux',
  OsName.osx: 'osx',
  OsName.unknown: 'unknown',
};
