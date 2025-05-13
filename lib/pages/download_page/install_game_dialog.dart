import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/widgets/dialog.dart';

class ForgeInfo {
  final String version;
  final String modifiedRaw;
  final DateTime modifiedDate;

  ForgeInfo({
    required this.version,
    required this.modifiedRaw,
    required this.modifiedDate,
  });

  factory ForgeInfo.fromJson(Map<String, dynamic> json) {
    final raw = json['modified'] as String;
    final dt = DateTime.parse(raw);
    return ForgeInfo(
      version: json['version'] as String,
      modifiedRaw: raw,
      modifiedDate: dt,
    );
  }

  String get formattedModified {
    return DateFormat('yyyy-MM-dd HH:mm').format(modifiedDate);
  }
}

class NeoforgeInfo {
  final String rawVersion;
  final String version;
  final String installerPath;

  NeoforgeInfo({
    required this.rawVersion,
    required this.version,
    required this.installerPath,
  });

  factory NeoforgeInfo.fromJson(Map<String, dynamic> json) {
    return NeoforgeInfo(
      rawVersion: json['rawVersion'] as String,
      version: json['version'] as String,
      installerPath: json['installerPath'] as String,
    );
  }
}

enum GameVersionType { none, forge, neoforge, fabric, quilt }

class InstallGamePage extends StatefulWidget {
  final String gameVersion;
  final String gameType;

  const InstallGamePage({
    Key? key,
    required this.gameVersion,
    required this.gameType,
  }) : super(key: key);

  @override
  _InstallGamePageState createState() => _InstallGamePageState();
}

class _InstallGamePageState extends State<InstallGamePage> {
  late final TextEditingController _gameNameController;
  bool _loadingList = true;

  // 数据列表
  List<ForgeInfo> _forges = [];
  List<NeoforgeInfo> _neoforges = [];

  // 统一选择状态
  GameVersionType _selectionType = GameVersionType.none;
  String? _selectedVersion;

  // 控制器
  final _forgeController = ExpansionTileController();
  final _neoforgeController = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    _gameNameController = TextEditingController(text: widget.gameVersion);

    Future.wait([
      _loadForgeByGameVersion(),
      _loadNeoforgeByGameVersion(),
    ]).then((results) {
      setState(() {
        _loadingList = false;
      });
    }).catchError((e) {
      setState(() {
        _loadingList = false;
      });
      debugPrint("列表加载失败：$e");
    });
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    super.dispose();
  }

  Future<void> _loadForgeByGameVersion() async {
    const urlTemplate = "https://bmclapi2.bangbang93.com/forge/minecraft/:id";
    final url = urlTemplate.replaceFirst(":id", widget.gameVersion);
    try {
      final resp = await Dio().get(url);
      if (resp.statusCode == 200) {
        final data = resp.data as List;
        final list = data
            .map((e) => ForgeInfo.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
        // 仅更新 _forges 列表
        setState(() {
          _forges = list;
        });
      }
    } catch (e) {
      debugPrint("加载 Forge 列表失败：$e");
    }
  }

  Future<void> _loadNeoforgeByGameVersion() async {
    const urlTemplate = "https://bmclapi2.bangbang93.com/neoforge/list/:id";
    final url = urlTemplate.replaceFirst(":id", widget.gameVersion);
    try {
      final resp = await Dio().get(url);
      if (resp.statusCode == 200) {
        final data = resp.data as List;
        final list = data
            .map((e) => NeoforgeInfo.fromJson(e as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();
        // 仅更新 _neoforges 列表
        setState(() {
          _neoforges = list;
        });
      }
    } catch (e) {
      debugPrint("加载 NeoForge 列表失败：$e");
    }
  }

  Widget _buildExpandableList<T>({
    required String title,
    required List<T> items,
    required GameVersionType type,
    required ExpansionTileController controller,
    required String Function(T) versionBuilder,
    String? Function(T)? subtitleBuilder,
  }) {
    final isSelected = _selectionType == type;
    final enabled = _selectionType == GameVersionType.none || isSelected;

    return ExpansionTile(
      controller: controller,
      title: Text(title),
      trailing: items.isEmpty
          ? const Text("不可用")
          : isSelected
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("已选择$_selectedVersion"),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectionType = GameVersionType.none;
                          _selectedVersion = null;
                          _gameNameController.text = widget.gameVersion;
                        });
                      },
                    ),
                  ],
                )
              : null,
      enabled: enabled && items.isNotEmpty,
      children: items.map((item) {
        final ver = versionBuilder(item);
        final isLatest = items.indexOf(item) == 0;
        final titleText = isLatest ? "$ver（最新版本）" : ver;
        return ListTile(
          leading: Image.asset(
            "assets/images/games/${title.toLowerCase()}.png",
            fit: BoxFit.contain,
          ),
          title: Text(titleText),
          subtitle:
              subtitleBuilder != null ? Text(subtitleBuilder(item)!) : null,
          onTap: enabled
              ? () {
                  setState(() {
                    _selectionType = type;
                    _selectedVersion = ver;
                    _gameNameController.text =
                        "${widget.gameVersion}-${title.toLowerCase()}-$ver";
                    controller.collapse();
                    debugPrint("选择了 $ver");
                    debugPrint("$type");
                    if (type == GameVersionType.forge) {
                      _neoforgeController.collapse();
                    } else {
                      _forgeController.collapse();
                    }
                  });
                }
              : null,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  if (widget.gameType == "正式版本")
                    Image.asset(
                      "assets/images/games/release.png",
                      fit: BoxFit.contain,
                      width: 100,
                    )
                  else
                    Image.asset(
                      "assets/images/games/snapshot.png",
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _gameNameController,
                      decoration: const InputDecoration(labelText: "游戏名称"),
                      maxLength: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loadingList)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    _buildExpandableList<ForgeInfo>(
                      title: "Forge",
                      items: _forges,
                      type: GameVersionType.forge,
                      controller: _forgeController,
                      versionBuilder: (f) => f.version,
                      subtitleBuilder: (f) => f.formattedModified,
                    ),
                    _buildExpandableList<NeoforgeInfo>(
                      title: "NeoForge",
                      items: _neoforges,
                      type: GameVersionType.neoforge,
                      controller: _neoforgeController,
                      versionBuilder: (n) => n.version,
                      subtitleBuilder: null,
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
      onCanceled: routePop,
      onConfirmed: () {
        // TODO: 下载assets, libraries, version.json, version.jar, 根据用户选择安装Forge
      },
    );
  }
}
