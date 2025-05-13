import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Forge 列表
  final _forgeListController = ExpansionTileController();
  List<ForgeInfo> _forges = [];
  bool _chooseForge = false;
  String? _chooseForgeVersion;

  // NeoForge 列表
  final _neoforgeListController = ExpansionTileController();
  List<NeoforgeInfo> _neoforges = [];
  bool _chooseNeoforge = false;
  String? _chooseNeoforgeVersion;

  @override
  void initState() {
    super.initState();
    _gameNameController = TextEditingController(text: widget.gameVersion);
    _loadForgeByGameVersion();
    _loadNeoforgeByGameVersion();
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
          // 按时间降序排序
          ..sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

        setState(() {
          _forges = list;
          _loadingList = false;
        });
      } else {
        setState(() => _loadingList = false);
      }
    } catch (e) {
      setState(() => _loadingList = false);
      debugPrint("加载 Forge 列表失败：$e");
    }
  }

  Future<void> _loadNeoforgeByGameVersion() async {
    const urlTemplate = "https://bmclapi2.bangbang93.com/neoforge/list/:id";
    final url = urlTemplate.replaceFirst(':id', widget.gameVersion);
    try {
      final resp = await Dio().get(url);
      if (resp.statusCode == 200) {
        final data = resp.data as List;
        final list = data
            .map((e) => NeoforgeInfo.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _neoforges = list;
          _loadingList = false;
        });
      } else {
        setState(() => _loadingList = false);
      }
    } catch (e) {
      setState(() => _loadingList = false);
      debugPrint("加载 Neoforge 列表失败：$e");
    }
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
                  // TODO: 逻辑待优化
                  ExpansionTile(
                    controller: _forgeListController,
                    title: const Text("Forge"),
                    trailing:
                        _chooseForge ? Text("已选择$_chooseForgeVersion") : null,
                    enabled: !_chooseNeoforge,
                    children: _forges.map((forge) {
                      return ListTile(
                        leading: Image.asset(
                          "assets/images/games/forge.png",
                          fit: BoxFit.contain,
                        ),
                        title: _forges.indexOf(forge) == 0
                            ? Text("${forge.version}（最新版本）")
                            : Text(forge.version),
                        subtitle: Text(forge.formattedModified),
                        onTap: () {
                          setState(() {
                            _gameNameController.text =
                                "${widget.gameVersion}-forge-${forge.version}";
                            _chooseForge = true;
                            _chooseForgeVersion = forge.version;
                            _forgeListController.collapse();
                            _neoforgeListController.collapse();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  ExpansionTile(
                    controller: _neoforgeListController,
                    title: const Text("NeoForge"),
                    trailing: _chooseNeoforge
                        ? Text("已选择$_chooseNeoforgeVersion")
                        : null,
                    enabled: !_chooseForge,
                    children: _neoforges.map((neoforge) {
                      return ListTile(
                        leading: Image.asset(
                          "assets/images/games/neoforge.png",
                          fit: BoxFit.contain,
                        ),
                        title: _neoforges.indexOf(neoforge) == 0
                            ? Text("${neoforge.version}（最新版本）")
                            : Text(neoforge.version),
                        onTap: () {
                          setState(() {
                            _gameNameController.text =
                                "${widget.gameVersion}-neoforge-${neoforge.version}";
                            _chooseNeoforge = true;
                            _chooseNeoforgeVersion = neoforge.version;
                            _chooseForge = false;
                            _forgeListController.collapse();
                            _neoforgeListController.collapse();
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              )
          ],
        ),
      ),
    ));
  }
}
