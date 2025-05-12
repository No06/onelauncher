import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  List<ForgeInfo> _forges = [];
  bool _loadingForges = true;

  @override
  void initState() {
    super.initState();
    _gameNameController = TextEditingController(text: widget.gameVersion);
    _loadForgeByGameVersion();
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
        final List data = resp.data as List;
        final list = data
            .map((e) => ForgeInfo.fromJson(e as Map<String, dynamic>))
            .toList()
          // 按时间降序排序
          ..sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

        setState(() {
          _forges = list;
          _loadingForges = false;
        });
      } else {
        setState(() => _loadingForges = false);
      }
    } catch (e) {
      setState(() => _loadingForges = false);
      debugPrint("加载 Forge 列表失败：$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Row(
                children: [
                  if (widget.gameType == "正式版本")
                    Image.asset(
                      "assets/images/games/release.png",
                      fit: BoxFit.contain,
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
              if (_loadingForges)
                const Center(child: CircularProgressIndicator())
              else
                ExpansionTile(
                  title: const Text("Forge"),
                  children: _forges.map((forge) {
                    return ListTile(
                      leading: Image.asset("assets/images/games/forge.png",
                          fit: BoxFit.contain),
                      title: Text(forge.version),
                      subtitle: Text(forge.formattedModified),
                      onTap: () {
                        _gameNameController.text =
                            "${widget.gameVersion}-forge-${forge.version}";
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
