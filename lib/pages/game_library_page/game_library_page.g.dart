// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_library_page.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$_FilterStateCWProxy {
  _FilterState name(String name);

  _FilterState collation(_GameCollation collation);

  _FilterState types(Set<_GameType> types);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `_FilterState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// _FilterState(...).copyWith(id: 12, name: "My name")
  /// ````
  _FilterState call({
    String? name,
    _GameCollation? collation,
    Set<_GameType>? types,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOf_FilterState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOf_FilterState.copyWith.fieldName(...)`
class _$_FilterStateCWProxyImpl implements _$_FilterStateCWProxy {
  const _$_FilterStateCWProxyImpl(this._value);

  final _FilterState _value;

  @override
  _FilterState name(String name) => this(name: name);

  @override
  _FilterState collation(_GameCollation collation) =>
      this(collation: collation);

  @override
  _FilterState types(Set<_GameType> types) => this(types: types);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `_FilterState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// _FilterState(...).copyWith(id: 12, name: "My name")
  /// ````
  _FilterState call({
    Object? name = const $CopyWithPlaceholder(),
    Object? collation = const $CopyWithPlaceholder(),
    Object? types = const $CopyWithPlaceholder(),
  }) {
    return _FilterState(
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      collation: collation == const $CopyWithPlaceholder() || collation == null
          ? _value.collation
          // ignore: cast_nullable_to_non_nullable
          : collation as _GameCollation,
      types: types == const $CopyWithPlaceholder() || types == null
          ? _value.types
          // ignore: cast_nullable_to_non_nullable
          : types as Set<_GameType>,
    );
  }
}

extension _$_FilterStateCopyWith on _FilterState {
  /// Returns a callable class that can be used as follows: `instanceOf_FilterState.copyWith(...)` or like so:`instanceOf_FilterState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$_FilterStateCWProxy get copyWith => _$_FilterStateCWProxyImpl(this);
}
