// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'displayName': instance.displayName,
      'skin': instance.skin,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'hashCode': instance.hashCode,
    };

const _$AccountTypeEnumMap = {
  AccountType.offline: 'offline',
  AccountType.microsoft: 'microsoft',
  AccountType.custom: 'custom',
};
