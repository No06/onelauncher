part of 'game_library_page.dart';

class _FilterRule {
  _FilterRule() {
    ever(_gameTypes, (callback) {
      _box.write(
        _gameTypesBoxKey,
        List.from(_gameTypes.map((type) => type.index)),
      );
    });
  }

  static final instance = _FilterRule();
  static GetStorage get _box => GetStorage("filterRule");
  static const _gameTypesBoxKey = "gameTypes";

  var searchValue = "";
  final _collationIndex =
      ReadWriteValueNotifier("collationIndex", 0, () => _box);
  final _gameTypes = Set<_GameType>.from(_box
              .read<List>(_gameTypesBoxKey)
              ?.map((index) => _GameType.values[index]) ??
          [])
      .obs;

  ReadWriteValueNotifier<int> get collationIndex => _collationIndex;
  GameCollation get collation => GameCollation.values[_collationIndex.val];
  set collation(GameCollation collation) =>
      _collationIndex.val = collation.index;

  RxSet<_GameType> get gameTypes => _gameTypes;
}

enum _GameType {
  release,
  snapshot,
  mod,
}

enum GameCollation {
  recentlyPlayed(name: "最近游玩"),
  byName(name: "名称");

  final String name;
  const GameCollation({required this.name});

  factory GameCollation.fromInt(int? x) => GameCollation.values[x ?? 0];
}
