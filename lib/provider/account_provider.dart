import 'dart:async';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/config/preference.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/microsoft_account.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';

part 'account_provider.g.dart';

@JsonSerializable()
@CopyWith()
class AccountState {
  AccountState({
    required this.selectedAccount,
    required this.accounts,
  });

  factory AccountState.fromJson(JsonMap json) => _$AccountStateFromJson(json);

  /// 被选中的用户
  final Account? selectedAccount;

  /// 可用的用户集合
  final Set<Account> accounts;

  JsonMap toJson() => _$AccountStateToJson(this);
}

class AccountStateNotifier extends StateNotifier<AccountState> {
  AccountStateNotifier() : super(_loadInitialState());

  static AccountState _loadInitialState() {
    AccountState? data;
    try {
      data = prefs.account;
    } catch (e) {
      e.printError();
    }
    return data ??
        AccountState(
          selectedAccount: null,
          accounts: {},
        );
  }

  Future<bool> _saveState() => prefs.setAccount(state);

  void updateSelectedAccount(Account account) {
    if (state.selectedAccount != account) {
      state = state.copyWith(selectedAccount: account);
      _saveState();
    }
  }

  Future<void> updateAccountProfile(MicrosoftAccount account) async {
    await account.updateProfile();
    unawaited(_saveState());
  }

  bool addAccount(Account value) {
    final updated = state.accounts.add(value);
    state = state.copyWith(selectedAccount: value, accounts: state.accounts);
    _saveState();
    return updated;
  }

  bool removeAccount(Account value) {
    final updated = state.accounts.remove(value);
    var selectedAccount = state.selectedAccount;
    if (selectedAccount == value) {
      selectedAccount = state.accounts.elementAtOrNull(0);
    }
    state = state.copyWith(
      accounts: state.accounts,
      selectedAccount: selectedAccount,
    );
    _saveState();
    return updated;
  }
}

final accountProvider =
    StateNotifierProvider<AccountStateNotifier, AccountState>((ref) {
  return AccountStateNotifier();
});
