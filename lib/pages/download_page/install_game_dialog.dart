import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/provider/game_path_provider.dart';
import 'package:one_launcher/widgets/dialog.dart';

// TODO: 代码结构优化

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
    return ForgeInfo(
      version: json['version'] as String,
      modifiedRaw: raw,
      modifiedDate: DateTime.parse(raw),
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

  const NeoforgeInfo({
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
  static const _apiBaseUrl = 'https://bmclapi2.bangbang93.com';
  static const _minecraftAssetsUrl = 'https://resources.download.minecraft.net';
  static const _batchSize = 32;

  late final TextEditingController _gameNameController;
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(minutes: 2),
    receiveTimeout: const Duration(minutes: 10),
    sendTimeout: const Duration(minutes: 2),
  ));

  bool _loadingList = true;

  List<ForgeInfo> _forges = [];
  List<NeoforgeInfo> _neoforges = [];

  GameVersionType _selectionType = GameVersionType.none;
  String? _selectedVersion;

  final _forgeController = ExpansionTileController();
  final _neoforgeController = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    _gameNameController = TextEditingController(text: widget.gameVersion);
    _loadModLoaderData();
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _loadModLoaderData() async {
    try {
      await Future.wait([
        _loadForgeByGameVersion(),
        _loadNeoforgeByGameVersion(),
      ]);
    } catch (e) {
      debugPrint("Failed to load mod loader data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _loadingList = false;
        });
      }
    }
  }

  Future<void> _loadForgeByGameVersion() async {
    try {
      final url = "$_apiBaseUrl/forge/minecraft/${widget.gameVersion}";
      final resp = await _dio.get(url);

      if (resp.statusCode == 200 && resp.data is List) {
        final list = (resp.data as List)
            .map((e) => ForgeInfo.fromJson(e as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();

        if (mounted) {
          setState(() {
            _forges = list;
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load Forge list: $e");
    }
  }

  Future<void> _loadNeoforgeByGameVersion() async {
    try {
      final url = "$_apiBaseUrl/neoforge/list/${widget.gameVersion}";
      final resp = await _dio.get(url);

      if (resp.statusCode == 200 && resp.data is List) {
        final list = (resp.data as List)
            .map((e) => NeoforgeInfo.fromJson(e as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();

        if (mounted) {
          setState(() {
            _neoforges = list;
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load NeoForge list: $e");
    }
  }

  // TODO: 由用户选择下载位置
  Future<String> get _installDir async {
    return GamePathState.launcherGamePaths.first.path;
  }

  Future<void> _downloadFile(String url, String savePath) async {
    final saveFile = File(savePath);
    if (!await saveFile.parent.exists()) {
      await saveFile.parent.create(recursive: true);
    }

    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(1);
            debugPrint('Download progress: $progress% ($received/$total)');
          }
        },
      );

      final file = File(savePath);
      if (!await file.exists() || await file.length() == 0) {
        throw Exception('Download failed - file is empty or does not exist');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception(
              'Connection timed out. Please check your internet connection and try again.');
        } else if (e.error is HandshakeException) {
          await _fallbackDownload(url, savePath);
          return;
        }
      }
      debugPrint('Download failed for $url: $e');
      throw Exception('Failed to download file: $e');
    }
  }

  Future<void> _fallbackDownload(String url, String savePath) async {
    debugPrint('Attempting fallback download for: $url');

    final httpClient = HttpClient()
      ..badCertificateCallback = (_, __, ___) => true;

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
    try {
      final installDir = await _installDir;
      final customId = _gameNameController.text;
      final versionDir = Directory('$installDir/versions/$customId');
      await versionDir.create(recursive: true);

      // TODO: 弹出安装进度条对话框

      // 获取版本信息
      final Map<String, dynamic> versionJson =
          await _downloadVersionJson(versionDir.path, customId);

      // 下载客户端jar
      await _downloadClientJar(versionJson, versionDir.path, customId);

      // 下载依赖库
      await _downloadLibraries(versionJson, installDir);

      // 下载资源包
      await _downloadAssets(versionJson, installDir);

      // FIXME: 下载ModLoader
      // if (_selectionType != GameVersionType.none) {
      //   await _installModLoader(versionDir.path);
      // }

      // 写入合并后的版本信息
      await _writeMergedVersionJson(versionJson, versionDir.path, customId);

      // 关闭窗口
      routePop();
    } catch (e) {
      debugPrint('Installation failed: $e');
      // TODO: 弹出失败信息
    }
  }

  Future<Map<String, dynamic>> _downloadVersionJson(
      String versionDirPath, String customId) async {
    final manifestResp = await _dio.get(
      'https://launchermeta.mojang.com/mc/game/version_manifest.json',
    );
    final manifest = manifestResp.data as Map<String, dynamic>;
    final entry = (manifest['versions'] as List)
        .firstWhere((v) => v['id'] == widget.gameVersion);
    final versionJsonUrl = entry['url'] as String;

    final versionJsonResp = await _dio.get(versionJsonUrl);
    // 保存至/versions/<customId>/<customId>.json
    await File('$versionDirPath/$customId.json')
        .writeAsString(jsonEncode(versionJsonResp.data));
    return versionJsonResp.data as Map<String, dynamic>;
  }

  Future<void> _downloadClientJar(Map<String, dynamic> versionJson,
      String versionDirPath, String customId) async {
    final clientUrl = versionJson['downloads']['client']['url'] as String;
    await _downloadFile(clientUrl, '$versionDirPath/$customId.jar');
  }

  Future<void> _downloadLibraries(
      Map<String, dynamic> versionJson, String installDir) async {
    final libraries = versionJson['libraries'] as List;
    final tasks = <Future>[];

    for (var lib in libraries) {
      final downloads = lib['downloads'] as Map<String, dynamic>?;
      if (downloads != null && downloads.containsKey('artifact')) {
        final artifact = downloads['artifact'] as Map<String, dynamic>;
        final libUrl = artifact['url'] as String;
        final path = artifact['path'] as String;
        final file = File('$installDir/libraries/$path');
        tasks.add(file.parent
            .create(recursive: true)
            .then((_) => _downloadFile(libUrl, file.path)));

        if (tasks.length >= _batchSize) {
          await Future.wait(tasks);
          tasks.clear();
        }
      }
    }

    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }
  }

  Future<void> _downloadAssets(
      Map<String, dynamic> versionJson, String installDir) async {
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
    if (isLegacy) {
      await Directory('${assetsDir.path}/virtual/$assetsIndex')
          .create(recursive: true);
    }

    if (indexJson.containsKey('objects')) {
      await _downloadAssetObjects(indexJson, objectsDir.path);
    } else {
      debugPrint('No assets found in index: $assetsIndex');
    }
  }

  Future<void> _downloadAssetObjects(
      Map<String, dynamic> indexJson, String objectsDirPath) async {
    final objects = indexJson['objects'] as Map<String, dynamic>;
    int downloaded = 0;
    final total = objects.length;
    final tasks = <Future>[];

    for (var entry in objects.entries) {
      final hash = (entry.value as Map<String, dynamic>)['hash'] as String;
      final size = (entry.value as Map<String, dynamic>)['size'] as int;
      final prefix = hash.substring(0, 2);
      final objectPath = '$objectsDirPath/$prefix/$hash';
      final objectFile = File(objectPath);

      if (!await objectFile.exists() || await objectFile.length() != size) {
        final url = '$_minecraftAssetsUrl/$prefix/$hash';
        tasks.add(_downloadFile(url, objectPath).then((_) {
          downloaded++;
          if (downloaded % 20 == 0) {
            debugPrint('Downloaded $downloaded/$total assets');
          }
        }));
      }

      if (tasks.length >= _batchSize) {
        await Future.wait(tasks);
        tasks.clear();
      }
    }

    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }
    debugPrint(
        'Asset download complete: $downloaded new files of $total total');
  }

  Future<void> _installModLoader(String versionDirPath) async {
    late String installerUrl;

    if (_selectionType == GameVersionType.forge) {
      final mcversion = widget.gameVersion;
      installerUrl = '$_apiBaseUrl/forge/download?mcversion=$mcversion'
          '&version=$_selectedVersion'
          '&category=universal'
          '&format=jar';
    } else if (_selectionType == GameVersionType.neoforge) {
      installerUrl =
          '$_apiBaseUrl/neoforge/version/$_selectedVersion/download/universal.jar';
    } else {
      return;
    }

    final installerPath = '$versionDirPath/installer.jar';
    await _downloadFile(installerUrl, installerPath);

    // FIXME: 安装ModLoader(没用)
    await Process.run('java',
        ['-jar', installerPath, '--installClient', '--target', versionDirPath]);
  }

  Future<void> _writeMergedVersionJson(Map<String, dynamic> versionJson,
      String versionDirPath, String customId) async {
    final merged = Map<String, dynamic>.from(versionJson)
      ..['id'] = customId
      ..['inheritsFrom'] = widget.gameVersion;

    await File('$versionDirPath/$customId.json')
        .writeAsString(jsonEncode(merged));
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
    final hasItems = items.isNotEmpty;

    return ExpansionTile(
      controller: controller,
      title: Text(title),
      trailing: !hasItems
          ? const Text("不可用")
          : isSelected
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("已选择$_selectedVersion"),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: _clearSelection,
                    ),
                  ],
                )
              : null,
      enabled: enabled && hasItems,
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
              ? () => _selectModLoader(type, ver, title.toLowerCase())
              : null,
        );
      }).toList(),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectionType = GameVersionType.none;
      _selectedVersion = null;
      _gameNameController.text = widget.gameVersion;
    });
  }

  void _selectModLoader(
      GameVersionType type, String version, String loaderName) {
    setState(() {
      _selectionType = type;
      _selectedVersion = version;
      _gameNameController.text = "${widget.gameVersion}-$loaderName-$version";

      _forgeController.collapse();
      _neoforgeController.collapse();
    });
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
                  Image.asset(
                    widget.gameType == "正式版本"
                        ? "assets/images/games/release.png"
                        : "assets/images/games/snapshot.png",
                    fit: BoxFit.contain,
                    width: 100,
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
