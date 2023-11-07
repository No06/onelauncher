// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
      theme: json['theme'] == null
          ? null
          : AppThemeConfig.fromJson(json['theme'] as Map<String, dynamic>),
      paths: (json['paths'] as List<dynamic>?)
          ?.map((e) => GamePath.fromJson(e as Map<String, dynamic>))
          .toSet(),
      selectedAccount: json['selectedAccount'] as String?,
      accounts: (json['accounts'] as List<dynamic>?)
          ?.map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toSet(),
      gameSetting: json['gameSetting'] == null
          ? null
          : GameSettingConfig.fromJson(
              json['gameSetting'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) {
  final val = <String, dynamic>{
    'theme': instance.theme,
    'gameSetting': instance.gameSetting,
    'paths': AppConfig._setToList(instance.paths),
    'accounts': AppConfig._setToList(instance.accounts),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('selectedAccount',
      AppConfig._selectedAccounttoString(instance.selectedAccount));
  return val;
}
