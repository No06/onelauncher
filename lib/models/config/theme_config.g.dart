// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppThemeConfig _$AppThemeConfigFromJson(Map<String, dynamic> json) =>
    AppThemeConfig(
      mode: $enumDecodeNullable(_$ThemeModeEnumMap, json['mode']),
      color: $enumDecodeNullable(_$SeedColorEnumMap, json['color']),
    );

Map<String, dynamic> _$AppThemeConfigToJson(AppThemeConfig instance) =>
    <String, dynamic>{
      'mode': _$ThemeModeEnumMap[instance.mode]!,
      'color': _$SeedColorEnumMap[instance.color]!,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$SeedColorEnumMap = {
  SeedColor.blue: 'blue',
};
