import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/skin.dart';
import 'package:json_annotation/json_annotation.dart';

part 'microsoft_account.g.dart';

@JsonSerializable()
class MicrosoftAccount extends Account {
  const MicrosoftAccount() : super(AccountType.microsoft);

  @override
  // TODO: implement uuid
  String get uuid => throw UnimplementedError();

  @override
  // TODO: implement displayName
  String get displayName => throw UnimplementedError();

  @override
  // TODO: implement skin
  Skin get skin => throw UnimplementedError();

  @override
  // TODO: implement type
  AccountType get type => throw UnimplementedError();

  factory MicrosoftAccount.fromJson(Map<String, dynamic> json) =>
      _$MicrosoftAccountFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MicrosoftAccountToJson(this);

  @override
  // TODO: implement token
  String get accessToken => throw UnimplementedError();

  @override
  int get hashCode => uuid.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! MicrosoftAccount) return false;
    return uuid == other.uuid;
  }
}
