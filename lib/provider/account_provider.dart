import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/json_map.dart';

part 'account_provider.g.dart';

@JsonSerializable()
@CopyWith()
class AccountState {
  /// 被选中的用户
  final Account? selectedAccount;

  /// 可用的用户集合
  final Set<Account> accounts;

  AccountState({
    required this.selectedAccount,
    required this.accounts,
  });

  JsonMap toJson() => _$AccountStateToJson(this);

  factory AccountState.fromJson(JsonMap json) => _$AccountStateFromJson(json);
}

class AccountStateNotifier extends StateNotifier<AccountState> {
  AccountStateNotifier() : super(_loadInitialState());

  static const storageKey = "accountState";

  static AccountState _loadInitialState() {
    final storedData = storage.read<JsonMap>(storageKey);
    try {
      if (storedData != null) return AccountState.fromJson(storedData);
    } catch (e) {
      e.printError();
    }
    return AccountState(
      selectedAccount: null,
      accounts: {},
    );
  }

  void _saveState() => storage.write(storageKey, state.toJson());

  void updateSelectedAccount(Account account) {
    state = state.copyWith(selectedAccount: account);
    _saveState();
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