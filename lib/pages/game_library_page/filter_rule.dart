part of 'game_library_page.dart';

class _FilterState {
  _FilterState({
    required this.name,
    required this.collation,
    required this.types,
  });

  final String name;
  final _GameCollation collation;
  final Set<_GameType> types;

  _FilterState copyWith({
    String? name,
    _GameCollation? collation,
    Set<_GameType>? types,
  }) {
    return _FilterState(
      name: name ?? this.name,
      collation: collation ?? this.collation,
      types: types ?? this.types,
    );
  }
}

class _FilterStateNotifier extends StateNotifier<_FilterState> {
  _FilterStateNotifier()
      : super(_FilterState(
          name: '',
          collation: _GameCollation.recentlyPlayed,
          types: <_GameType>{},
        ));

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateCollation(_GameCollation collation) {
    state = state.copyWith(collation: collation);
  }

  void updateTypeWithSelectedValue(_GameType type, bool isSelected) {
    final newTypes = Set<_GameType>.from(state.types);
    if (isSelected) {
      newTypes.add(type);
    } else {
      newTypes.remove(type);
    }
    state = state.copyWith(types: newTypes);
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

  final String name;

  const _GameType(this.name);

  factory _GameType.fromGame(Game game) =>
      game.isModVersion ? mod : _GameType.fromGameType(game.data.type);
  factory _GameType.fromGameType(GameType type) =>
      type == GameType.release ? release : snapshot;
}

enum _GameCollation {
  recentlyPlayed(name: "最近游玩"),
  byName(name: "名称");

  final String name;
  const _GameCollation({required this.name});
}
