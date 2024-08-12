// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xbox_oauth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XboxOAuthToken _$XboxOAuthTokenFromJson(Map<String, dynamic> json) =>
    XboxOAuthToken(
      DateTime.parse(json['IssueInstant'] as String),
      DateTime.parse(json['NotAfter'] as String),
      json['Token'] as String,
      DisplayClaims.fromJson(json['DisplayClaims'] as Map<String, dynamic>),
    );

DisplayClaims _$DisplayClaimsFromJson(Map<String, dynamic> json) =>
    DisplayClaims(
      xui: (json['xui'] as List<dynamic>)
          .map((e) => Xui.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Xui _$XuiFromJson(Map<String, dynamic> json) => Xui(
      uhs: json['uhs'] as String,
    );
