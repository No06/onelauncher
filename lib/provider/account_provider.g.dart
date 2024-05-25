// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_provider.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountStateCWProxy {
  AccountState selectedAccount(Account? selectedAccount);

  AccountState accounts(Set<Account> accounts);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountState(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountState call({
    Account? selectedAccount,
    Set<Account>? accounts,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountState.copyWith.fieldName(...)`
class _$AccountStateCWProxyImpl implements _$AccountStateCWProxy {
  const _$AccountStateCWProxyImpl(this._value);

  final AccountState _value;

  @override
  AccountState selectedAccount(Account? selectedAccount) =>
      this(selectedAccount: selectedAccount);

  @override
  AccountState accounts(Set<Account> accounts) => this(accounts: accounts);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountState(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountState call({
    Object? selectedAccount = const $CopyWithPlaceholder(),
    Object? accounts = const $CopyWithPlaceholder(),
  }) {
    return AccountState(
      selectedAccount: selectedAccount == const $CopyWithPlaceholder()
          ? _value.selectedAccount
          // ignore: cast_nullable_to_non_nullable
          : selectedAccount as Account?,
      accounts: accounts == const $CopyWithPlaceholder() || accounts == null
          ? _value.accounts
          // ignore: cast_nullable_to_non_nullable
          : accounts as Set<Account>,
    );
  }
}

extension $AccountStateCopyWith on AccountState {
  /// Returns a callable class that can be used as follows: `instanceOfAccountState.copyWith(...)` or like so:`instanceOfAccountState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountStateCWProxy get copyWith => _$AccountStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountState _$AccountStateFromJson(Map<String, dynamic> json) => AccountState(
      selectedAccount: json['selectedAccount'] == null
          ? null
          : Account.fromJson(json['selectedAccount'] as Map<String, dynamic>),
      accounts: (json['accounts'] as List<dynamic>)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toSet(),
    );

Map<String, dynamic> _$AccountStateToJson(AccountState instance) =>
    <String, dynamic>{
      'selectedAccount': instance.selectedAccount,
      'accounts': instance.accounts.toList(),
    };
