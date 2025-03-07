// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'microsoft_account.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MicrosoftAccountCWProxy {
  MicrosoftAccount uuid(String uuid);

  MicrosoftAccount displayName(String displayName);

  MicrosoftAccount accessToken(String accessToken);

  MicrosoftAccount refreshToken(String refreshToken);

  MicrosoftAccount notAfter(int notAfter);

  MicrosoftAccount loginType(MicrosoftLoginType loginType);

  MicrosoftAccount skins(List<OnlineSkin> skins);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MicrosoftAccount(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MicrosoftAccount(...).copyWith(id: 12, name: "My name")
  /// ````
  MicrosoftAccount call({
    String? uuid,
    String? displayName,
    String? accessToken,
    String? refreshToken,
    int? notAfter,
    MicrosoftLoginType? loginType,
    List<OnlineSkin>? skins,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMicrosoftAccount.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMicrosoftAccount.copyWith.fieldName(...)`
class _$MicrosoftAccountCWProxyImpl implements _$MicrosoftAccountCWProxy {
  const _$MicrosoftAccountCWProxyImpl(this._value);

  final MicrosoftAccount _value;

  @override
  MicrosoftAccount uuid(String uuid) => this(uuid: uuid);

  @override
  MicrosoftAccount displayName(String displayName) =>
      this(displayName: displayName);

  @override
  MicrosoftAccount accessToken(String accessToken) =>
      this(accessToken: accessToken);

  @override
  MicrosoftAccount refreshToken(String refreshToken) =>
      this(refreshToken: refreshToken);

  @override
  MicrosoftAccount notAfter(int notAfter) => this(notAfter: notAfter);

  @override
  MicrosoftAccount loginType(MicrosoftLoginType loginType) =>
      this(loginType: loginType);

  @override
  MicrosoftAccount skins(List<OnlineSkin> skins) => this(skins: skins);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MicrosoftAccount(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MicrosoftAccount(...).copyWith(id: 12, name: "My name")
  /// ````
  MicrosoftAccount call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? accessToken = const $CopyWithPlaceholder(),
    Object? refreshToken = const $CopyWithPlaceholder(),
    Object? notAfter = const $CopyWithPlaceholder(),
    Object? loginType = const $CopyWithPlaceholder(),
    Object? skins = const $CopyWithPlaceholder(),
  }) {
    return MicrosoftAccount(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      displayName:
          displayName == const $CopyWithPlaceholder() || displayName == null
              ? _value.displayName
              // ignore: cast_nullable_to_non_nullable
              : displayName as String,
      accessToken:
          accessToken == const $CopyWithPlaceholder() || accessToken == null
              ? _value.accessToken
              // ignore: cast_nullable_to_non_nullable
              : accessToken as String,
      refreshToken:
          refreshToken == const $CopyWithPlaceholder() || refreshToken == null
              ? _value.refreshToken
              // ignore: cast_nullable_to_non_nullable
              : refreshToken as String,
      notAfter: notAfter == const $CopyWithPlaceholder() || notAfter == null
          ? _value.notAfter
          // ignore: cast_nullable_to_non_nullable
          : notAfter as int,
      loginType: loginType == const $CopyWithPlaceholder() || loginType == null
          ? _value.loginType
          // ignore: cast_nullable_to_non_nullable
          : loginType as MicrosoftLoginType,
      skins: skins == const $CopyWithPlaceholder() || skins == null
          ? _value.skins
          // ignore: cast_nullable_to_non_nullable
          : skins as List<OnlineSkin>,
    );
  }
}

extension $MicrosoftAccountCopyWith on MicrosoftAccount {
  /// Returns a callable class that can be used as follows: `instanceOfMicrosoftAccount.copyWith(...)` or like so:`instanceOfMicrosoftAccount.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MicrosoftAccountCWProxy get copyWith => _$MicrosoftAccountCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MicrosoftAccount _$MicrosoftAccountFromJson(Map<String, dynamic> json) =>
    MicrosoftAccount(
      uuid: json['uuid'] as String,
      displayName: json['displayName'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      notAfter: (json['notAfter'] as num).toInt(),
      loginType: $enumDecode(_$MicrosoftLoginTypeEnumMap, json['loginType']),
    );

Map<String, dynamic> _$MicrosoftAccountToJson(MicrosoftAccount instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'uuid': instance.uuid,
      'accessToken': instance.accessToken,
      'loginType': _$MicrosoftLoginTypeEnumMap[instance.loginType]!,
      'refreshToken': instance.refreshToken,
      'notAfter': instance.notAfter,
    };

const _$MicrosoftLoginTypeEnumMap = {
  MicrosoftLoginType.devicecode: 'devicecode',
  MicrosoftLoginType.oauth20: 'oauth20',
};
