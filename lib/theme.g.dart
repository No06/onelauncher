// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppTheme _$AppThemeFromJson(Map<String, dynamic> json) => AppTheme(
      mode: $enumDecodeNullable(_$ThemeModeEnumMap, json['mode']) ??
          ThemeMode.system,
      color: $enumDecodeNullable(_$SeedColorEnumMap, json['color']) ??
          SeedColor.blue,
    );

Map<String, dynamic> _$AppThemeToJson(AppTheme instance) => <String, dynamic>{
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
