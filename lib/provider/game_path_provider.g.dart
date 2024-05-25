// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_path_provider.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GamePathStateCWProxy {
  GamePathState paths(Set<GamePath>? paths);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GamePathState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GamePathState(...).copyWith(id: 12, name: "My name")
  /// ````
  GamePathState call({
    Set<GamePath>? paths,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGamePathState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGamePathState.copyWith.fieldName(...)`
class _$GamePathStateCWProxyImpl implements _$GamePathStateCWProxy {
  const _$GamePathStateCWProxyImpl(this._value);

  final GamePathState _value;

  @override
  GamePathState paths(Set<GamePath>? paths) => this(paths: paths);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GamePathState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GamePathState(...).copyWith(id: 12, name: "My name")
  /// ````
  GamePathState call({
    Object? paths = const $CopyWithPlaceholder(),
  }) {
    return GamePathState(
      paths: paths == const $CopyWithPlaceholder()
          ? _value.paths
          // ignore: cast_nullable_to_non_nullable
          : paths as Set<GamePath>?,
    );
  }
}

extension $GamePathStateCopyWith on GamePathState {
  /// Returns a callable class that can be used as follows: `instanceOfGamePathState.copyWith(...)` or like so:`instanceOfGamePathState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GamePathStateCWProxy get copyWith => _$GamePathStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GamePathState _$GamePathStateFromJson(Map<String, dynamic> json) =>
    GamePathState(
      paths: (json['paths'] as List<dynamic>?)
          ?.map((e) => GamePath.fromJson(e as Map<String, dynamic>))
          .toSet(),
    );

Map<String, dynamic> _$GamePathStateToJson(GamePathState instance) =>
    <String, dynamic>{
      'paths': instance.paths.toList(),
    };
