part of 'game_library_page.dart';

class _FilterRule extends ChangeNotifier {
  _FilterRule() {
    _collationIndex.addListener(notifyListeners);
    ever(_gameTypes, (callback) {
      notifyListeners();
      _box.write(
        _gameTypesBoxKey,
        List.from(callback.map((type) => type.index)),
      );
    });
  }

  static final instance = _FilterRule();
  static GetStorage get _box => GetStorage();
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
  mod;

  const _GameType();
  factory _GameType.fromGame(Game game) =>
      game.isModVersion ? mod : _GameType.fromGameType(game.version.type);
  factory _GameType.fromGameType(GameType type) =>
      type == GameType.release ? release : snapshot;
}

enum GameCollation {
  recentlyPlayed(name: "最近游玩"),
  byName(name: "名称");

  final String name;
  const GameCollation({required this.name});

  factory GameCollation.fromInt(int? x) => GameCollation.values[x ?? 0];
}
