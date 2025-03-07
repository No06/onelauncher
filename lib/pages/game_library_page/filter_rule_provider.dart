part of 'game_library_page.dart';

@CopyWith()
class _FilterState {
  _FilterState({
    required this.name,
    required this.collation,
    required this.types,
  });

  factory _FilterState.fromJson(JsonMap json) => _FilterState(
        name: "",
        collation: _GameCollation.values[json['collation'] as int],
        types: (json['types'] as List)
            .map((index) => _GameType.values[index as int])
            .toSet(),
      );

  final String name;
  final _GameCollation collation;
  final Set<_GameType> types;

  JsonMap toJson() => {
        'collation': collation.index,
        'types': types.map((e) => e.index).toList(),
      };
}

class _FilterStateNotifier extends StateNotifier<_FilterState> {
  _FilterStateNotifier() : super(_loadInitialState());

  static _FilterState _loadInitialState() {
    _FilterState? data;
    try {
      data = prefs.getFromJson(
        PreferenceKeys.filterState,
        _FilterState.fromJson,
      );
    } catch (e) {
      e.printError();
    }
    return data ??
        _FilterState(
          name: '',
          collation: _GameCollation.recentlyPlayed,
          types: <_GameType>{},
        );
  }

  void _saveState() {
    prefs.setToJson(PreferenceKeys.filterState, state.toJson);
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateCollation(_GameCollation collation) {
    state = state.copyWith(collation: collation);
    _saveState();
  }

  void updateTypeWithSelectedValue(_GameType type, {required bool isSelected}) {
    final newTypes = Set<_GameType>.from(state.types);
    if (isSelected) {
      newTypes.add(type);
    } else {
      newTypes.remove(type);
    }
    state = state.copyWith(types: newTypes);
    _saveState();
  }
}

final _filterStateProvider =
    StateNotifierProvider<_FilterStateNotifier, _FilterState>((ref) {
  return _FilterStateNotifier();
});

enum _GameType {
  release("正式版"),
  snapshot("快照"),
  mod("Mod版");

  const _GameType(this.name);

  final String name;
}

enum _GameCollation {
  recentlyPlayed(name: "最近游玩"),
  byName(name: "名称");

  const _GameCollation({required this.name});

  final String name;
}
