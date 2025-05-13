import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/provider/game_path_provider.dart';
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

enum GameVersionType { none, forge, neoforge }

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
            .reversed
            .toList();

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

        setState(() {
          _neoforges = list;
        });
      }
    } catch (e) {
      debugPrint("加载 NeoForge 列表失败：$e");
    }
  }

  Future<String> get _installDir async {
    return await GamePathState.launcherGamePaths.first.path;
  }

  Future<void> _downloadFile(String url, String savePath) async {
    final dio = Dio();

    final saveFile = File(savePath);
    if (!await saveFile.parent.exists()) {
      await saveFile.parent.create(recursive: true);
    }

    try {
      final options = Options(
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(minutes: 2),
      );

      await dio.download(
        url,
        savePath,
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(1);
            debugPrint('Download progress: $progress% ($received/$total)');
          }
        },
      );

      final file = File(savePath);
      if (!await file.exists() || await file.length() == 0) {
        throw Exception(
            'Download failed - file is empty or does not exist: $savePath');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          debugPrint('Download timeout for $url: ${e.message}');
          throw Exception(
              'Connection timed out. Please check your internet connection and try again.');
        } else if (e.error is HandshakeException) {
          debugPrint('SSL handshake failed for $url: ${e.message}');
          await _fallbackDownload(url, savePath);
          return;
        }
      }

      debugPrint('Download failed for $url: $e');
      throw Exception('Failed to download file: ${e.toString()}');
    }
  }

  Future<void> _fallbackDownload(String url, String savePath) async {
    debugPrint('Attempting fallback download for: $url');

    final httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    try {
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Failed with status code: ${response.statusCode}');
      }

      final file = File(savePath);
      final sink = file.openWrite();
      await sink.addStream(response);
      await sink.close();

      if (!await file.exists() || await file.length() == 0) {
        throw Exception('Fallback download failed - file is empty or missing');
      }
    } catch (e) {
      debugPrint('Fallback download failed: $e');
      throw Exception(
          'All download methods failed. Please check your connection or try an alternative source.');
    } finally {
      httpClient.close();
    }
  }

  Future<void> _onConfirmed() async {
    final installDir = await _installDir;
    final customId = _gameNameController.text;

    // 获取version_manifest (通过)
    final manifestResp = await Dio().get(
      'https://launchermeta.mojang.com/mc/game/version_manifest.json',
    );
    final manifest = manifestResp.data as Map<String, dynamic>;
    final entry = (manifest['versions'] as List)
        .firstWhere((v) => v['id'] == widget.gameVersion);
    final versionJsonUrl = entry['url'] as String;

    // 获取version.json (通过)
    final versionJsonResp = await Dio().get(versionJsonUrl);
    final versionJson = versionJsonResp.data as Map<String, dynamic>;

    // 创建versions文件夹 (通过)
    final versionDir = Directory('$installDir/versions/$customId');
    await versionDir.create(recursive: true);

    // 下载client jar (通过)
    final clientUrl = versionJson['downloads']['client']['url'] as String;
    await _downloadFile(clientUrl, '${versionDir.path}/$customId.jar');

    // 下载libraries (通过)
    for (var lib in versionJson['libraries'] as List) {
      final downloads = lib['downloads'] as Map<String, dynamic>?;
      if (downloads != null && downloads.containsKey('artifact')) {
        final artifact = downloads['artifact'] as Map<String, dynamic>;
        final libUrl = artifact['url'] as String;
        final path = artifact['path'] as String;
        final file = File('$installDir/libraries/$path');
        await file.parent.create(recursive: true);
        await _downloadFile(libUrl, file.path);
      }
    }

    // 下载assets (TODO: objects无法成功下载，待修复)
    final assetsIndex = versionJson['assets'] as String;
    final indexInfo = versionJson['assetIndex'] as Map<String, dynamic>;
    final assetsDir = Directory('$installDir/assets');
    final objectsDir = Directory('${assetsDir.path}/objects');
    final indexesDir = Directory('${assetsDir.path}/indexes');

    await indexesDir.create(recursive: true);
    await objectsDir.create(recursive: true);

    final indexUrl = indexInfo['url'] as String;
    final indexFile = File('${indexesDir.path}/$assetsIndex.json');
    await _downloadFile(indexUrl, indexFile.path);

    final indexContent = await indexFile.readAsString();
    final indexJson = jsonDecode(indexContent) as Map<String, dynamic>;

    final isLegacy = assetsIndex == 'legacy' || assetsIndex == 'pre-1.6';
    Directory? virtualDir;
    if (isLegacy) {
      virtualDir = Directory('${assetsDir.path}/virtual/$assetsIndex');
      await virtualDir.create(recursive: true);
    }

    if (indexJson.containsKey('objects')) {
      final objects = indexJson['objects'] as Map<String, dynamic>;

      int downloaded = 0;
      final total = objects.length;

      for (var entry in objects.entries) {
        final resourcePath = entry.key;
        final info = entry.value as Map<String, dynamic>;
        final hash = info['hash'] as String;
        final size = info['size'] as int;

        final hashPrefix = hash.substring(0, 2);
        final objectPath = '${objectsDir.path}/$hashPrefix/$hash';
        final objectFile = File(objectPath);

        await objectFile.parent.create(recursive: true);

        // Download the asset if it doesn't exist or has wrong size
        if (!await objectFile.exists() || await objectFile.length() != size) {
          final assetUrl =
              'http://resources.download.minecraft.net/$hashPrefix/$hash';
          await _downloadFile(assetUrl, objectPath);
          downloaded++;
          if (downloaded % 20 == 0) {
            debugPrint('Downloaded $downloaded/$total assets');
          }
        }

        // For legacy versions, also copy to the virtual directory
        if (isLegacy && virtualDir != null) {
          final virtualPath = '${virtualDir.path}/$resourcePath';
          final virtualFile = File(virtualPath);

          // Ensure parent directory exists
          await virtualFile.parent.create(recursive: true);

          // Copy from objects to virtual path (if needed)
          if (!await virtualFile.exists() ||
              await virtualFile.length() != size) {
            await objectFile.copy(virtualPath);
          }
        }
      }

      debugPrint(
          'Asset download complete: $downloaded new files of $total total');
    } else {
      debugPrint('No assets found in index: $assetsIndex');
    }

    // 下载Forge/NeoForge Jar
    late String installerUrl;
    if (_selectionType == GameVersionType.forge) {
      installerUrl =
          'https://bmclapi2.bangbang93.com/forge/download/$_selectedVersion';
    } else if (_selectionType == GameVersionType.neoforge) {
      final nf = _neoforges.firstWhere((n) => n.version == _selectedVersion);
      installerUrl =
          'https://bmclapi2.bangbang93.com/neoforge/download/${nf.rawVersion}';
    } else {
      return;
    }
    final installerPath = '${versionDir.path}/installer.jar';
    await _downloadFile(installerUrl, installerPath);

    // 运行Installer
    await Process.run('java', [
      '-jar',
      installerPath,
      '--installClient',
      '--target',
      versionDir.path
    ]);

    // 写入合并版本json
    final merged = Map<String, dynamic>.from(versionJson)
      ..['id'] = customId
      ..['inheritsFrom'] = widget.gameVersion;
    await File('${versionDir.path}/$customId.json')
        .writeAsString(jsonEncode(merged));

    // TODO: 弹出安装提示框

    // 关闭对话框
    routePop();
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
      onConfirmed: _onConfirmed,
    );
  }
}
