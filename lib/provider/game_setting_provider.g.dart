// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_setting_provider.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GameSettingCWProxy {
  GameSetting java(Java? java);

  GameSetting jvmArgs(String? jvmArgs);

  GameSetting autoMemory(bool autoMemory);

  GameSetting maxMemory(int maxMemory);

  GameSetting fullScreen(bool fullScreen);

  GameSetting width(int width);

  GameSetting height(int height);

  GameSetting recordLog(bool recordLog);

  GameSetting args(String args);

  GameSetting serverAddress(String serverAddress);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GameSetting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GameSetting(...).copyWith(id: 12, name: "My name")
  /// ````
  GameSetting call({
    Java? java,
    String? jvmArgs,
    bool? autoMemory,
    int? maxMemory,
    bool? fullScreen,
    int? width,
    int? height,
    bool? recordLog,
    String? args,
    String? serverAddress,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGameSetting.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGameSetting.copyWith.fieldName(...)`
class _$GameSettingCWProxyImpl implements _$GameSettingCWProxy {
  const _$GameSettingCWProxyImpl(this._value);

  final GameSetting _value;

  @override
  GameSetting java(Java? java) => this(java: java);

  @override
  GameSetting jvmArgs(String? jvmArgs) => this(jvmArgs: jvmArgs);

  @override
  GameSetting autoMemory(bool autoMemory) => this(autoMemory: autoMemory);

  @override
  GameSetting maxMemory(int maxMemory) => this(maxMemory: maxMemory);

  @override
  GameSetting fullScreen(bool fullScreen) => this(fullScreen: fullScreen);

  @override
  GameSetting width(int width) => this(width: width);

  @override
  GameSetting height(int height) => this(height: height);

  @override
  GameSetting recordLog(bool recordLog) => this(recordLog: recordLog);

  @override
  GameSetting args(String args) => this(args: args);

  @override
  GameSetting serverAddress(String serverAddress) =>
      this(serverAddress: serverAddress);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GameSetting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GameSetting(...).copyWith(id: 12, name: "My name")
  /// ````
  GameSetting call({
    Object? java = const $CopyWithPlaceholder(),
    Object? jvmArgs = const $CopyWithPlaceholder(),
    Object? autoMemory = const $CopyWithPlaceholder(),
    Object? maxMemory = const $CopyWithPlaceholder(),
    Object? fullScreen = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? recordLog = const $CopyWithPlaceholder(),
    Object? args = const $CopyWithPlaceholder(),
    Object? serverAddress = const $CopyWithPlaceholder(),
  }) {
    return GameSetting(
      java: java == const $CopyWithPlaceholder()
          ? _value.java
          // ignore: cast_nullable_to_non_nullable
          : java as Java?,
      jvmArgs: jvmArgs == const $CopyWithPlaceholder()
          ? _value.jvmArgs
          // ignore: cast_nullable_to_non_nullable
          : jvmArgs as String?,
      autoMemory:
          autoMemory == const $CopyWithPlaceholder() || autoMemory == null
              ? _value.autoMemory
              // ignore: cast_nullable_to_non_nullable
              : autoMemory as bool,
      maxMemory: maxMemory == const $CopyWithPlaceholder() || maxMemory == null
          ? _value.maxMemory
          // ignore: cast_nullable_to_non_nullable
          : maxMemory as int,
      fullScreen:
          fullScreen == const $CopyWithPlaceholder() || fullScreen == null
              ? _value.fullScreen
              // ignore: cast_nullable_to_non_nullable
              : fullScreen as bool,
      width: width == const $CopyWithPlaceholder() || width == null
          ? _value.width
          // ignore: cast_nullable_to_non_nullable
          : width as int,
      height: height == const $CopyWithPlaceholder() || height == null
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as int,
      recordLog: recordLog == const $CopyWithPlaceholder() || recordLog == null
          ? _value.recordLog
          // ignore: cast_nullable_to_non_nullable
          : recordLog as bool,
      args: args == const $CopyWithPlaceholder() || args == null
          ? _value.args
          // ignore: cast_nullable_to_non_nullable
          : args as String,
      serverAddress:
          serverAddress == const $CopyWithPlaceholder() || serverAddress == null
              ? _value.serverAddress
              // ignore: cast_nullable_to_non_nullable
              : serverAddress as String,
    );
  }
}

extension $GameSettingCopyWith on GameSetting {
  /// Returns a callable class that can be used as follows: `instanceOfGameSetting.copyWith(...)` or like so:`instanceOfGameSetting.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GameSettingCWProxy get copyWith => _$GameSettingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameSetting _$GameSettingFromJson(Map<String, dynamic> json) => GameSetting(
      java: json['java'] == null
          ? null
          : Java.fromJson(json['java'] as Map<String, dynamic>),
      jvmArgs: json['jvmArgs'] as String?,
      autoMemory: json['autoMemory'] as bool? ?? true,
      maxMemory: (json['maxMemory'] as num?)?.toInt() ?? 2048,
      fullScreen: json['fullScreen'] as bool? ?? false,
      width: (json['width'] as num?)?.toInt() ?? 854,
      height: (json['height'] as num?)?.toInt() ?? 480,
      recordLog: json['recordLog'] as bool? ?? false,
      args: json['args'] as String? ?? "",
      serverAddress: json['serverAddress'] as String? ?? "",
    );

Map<String, dynamic> _$GameSettingToJson(GameSetting instance) =>
    <String, dynamic>{
      'java': instance.java,
      'jvmArgs': instance.jvmArgs,
      'autoMemory': instance.autoMemory,
      'maxMemory': instance.maxMemory,
      'fullScreen': instance.fullScreen,
      'width': instance.width,
      'height': instance.height,
      'recordLog': instance.recordLog,
      'args': instance.args,
      'serverAddress': instance.serverAddress,
    };
