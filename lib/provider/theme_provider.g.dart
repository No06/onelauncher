// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppThemeStateCWProxy {
  AppThemeState mode(ThemeMode mode);

  AppThemeState color(Color color);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AppThemeState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AppThemeState(...).copyWith(id: 12, name: "My name")
  /// ````
  AppThemeState call({
    ThemeMode? mode,
    Color? color,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAppThemeState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAppThemeState.copyWith.fieldName(...)`
class _$AppThemeStateCWProxyImpl implements _$AppThemeStateCWProxy {
  const _$AppThemeStateCWProxyImpl(this._value);

  final AppThemeState _value;

  @override
  AppThemeState mode(ThemeMode mode) => this(mode: mode);

  @override
  AppThemeState color(Color color) => this(color: color);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AppThemeState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AppThemeState(...).copyWith(id: 12, name: "My name")
  /// ````
  AppThemeState call({
    Object? mode = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
  }) {
    return AppThemeState(
      mode: mode == const $CopyWithPlaceholder() || mode == null
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as ThemeMode,
      color: color == const $CopyWithPlaceholder() || color == null
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as Color,
    );
  }
}

extension $AppThemeStateCopyWith on AppThemeState {
  /// Returns a callable class that can be used as follows: `instanceOfAppThemeState.copyWith(...)` or like so:`instanceOfAppThemeState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AppThemeStateCWProxy get copyWith => _$AppThemeStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppThemeState _$AppThemeStateFromJson(Map<String, dynamic> json) =>
    AppThemeState(
      mode: const ThemeModeJsonConverter()
          .fromJson((json['mode'] as num).toInt()),
      color: const ColorJsonConverter()
          .fromJson(json['color'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppThemeStateToJson(AppThemeState instance) =>
    <String, dynamic>{
      'mode': const ThemeModeJsonConverter().toJson(instance.mode),
      'color': const ColorJsonConverter().toJson(instance.color),
    };
