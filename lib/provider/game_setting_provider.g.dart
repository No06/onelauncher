// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_setting_provider.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GameSettingStateCWProxy {
  GameSettingState java(Java? java);

  GameSettingState jvmArgs(String? jvmArgs);

  GameSettingState autoMemory(bool autoMemory);

  GameSettingState maxMemory(int maxMemory);

  GameSettingState fullScreen(bool fullScreen);

  GameSettingState width(int width);

  GameSettingState height(int height);

  GameSettingState recordLog(bool recordLog);

  GameSettingState args(String args);

  GameSettingState serverAddress(String serverAddress);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GameSettingState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GameSettingState(...).copyWith(id: 12, name: "My name")
  /// ````
  GameSettingState call({
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

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGameSettingState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGameSettingState.copyWith.fieldName(...)`
class _$GameSettingStateCWProxyImpl implements _$GameSettingStateCWProxy {
  const _$GameSettingStateCWProxyImpl(this._value);

  final GameSettingState _value;

  @override
  GameSettingState java(Java? java) => this(java: java);

  @override
  GameSettingState jvmArgs(String? jvmArgs) => this(jvmArgs: jvmArgs);

  @override
  GameSettingState autoMemory(bool autoMemory) => this(autoMemory: autoMemory);

  @override
  GameSettingState maxMemory(int maxMemory) => this(maxMemory: maxMemory);

  @override
  GameSettingState fullScreen(bool fullScreen) => this(fullScreen: fullScreen);

  @override
  GameSettingState width(int width) => this(width: width);

  @override
  GameSettingState height(int height) => this(height: height);

  @override
  GameSettingState recordLog(bool recordLog) => this(recordLog: recordLog);

  @override
  GameSettingState args(String args) => this(args: args);

  @override
  GameSettingState serverAddress(String serverAddress) =>
      this(serverAddress: serverAddress);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GameSettingState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GameSettingState(...).copyWith(id: 12, name: "My name")
  /// ````
  GameSettingState call({
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
    return GameSettingState(
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

extension $GameSettingStateCopyWith on GameSettingState {
  /// Returns a callable class that can be used as follows: `instanceOfGameSettingState.copyWith(...)` or like so:`instanceOfGameSettingState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GameSettingStateCWProxy get copyWith => _$GameSettingStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameSettingState _$GameSettingStateFromJson(Map<String, dynamic> json) =>
    GameSettingState(
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

Map<String, dynamic> _$GameSettingStateToJson(GameSettingState instance) =>
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
