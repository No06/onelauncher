part of 'download_page.dart';

class VersionManifest {
  final String latestRelease;
  final String latestSnapshot;
  final List<GameVersion> releases;
  final List<GameVersion> snapshots;

  VersionManifest({
    required this.latestRelease,
    required this.latestSnapshot,
    required this.releases,
    required this.snapshots,
  });

  factory VersionManifest.fromJson(Map<String, dynamic> json) {
    final versions = (json['versions'] as List)
        .map((e) => GameVersion.fromJson(e as Map<String, dynamic>))
        .toList();

    return VersionManifest(
      latestRelease: json['latest']['release'] as String,
      latestSnapshot: json['latest']['snapshot'] as String,
      releases: versions.where((v) => v.type == 'release').toList(),
      snapshots: versions.where((v) => v.type == 'snapshot').toList(),
    );
  }
}

// 获取版本列表
final versionManifestProvider = FutureProvider<VersionManifest>((ref) async {
  const url = 'https://launchermeta.mojang.com/mc/game/version_manifest.json';
  final response = await Dio().get(url);
  return VersionManifest.fromJson(response.data as Map<String, dynamic>);
});

class _GameDownloadPage extends ConsumerWidget {
  const _GameDownloadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifestAsync = ref.watch(versionManifestProvider);

    return Scaffold(
      body: manifestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(
          child: Text('加载失败，请检查网络或使用代理。'),
        ),
        data: (manifest) => VersionListView(manifest: manifest),
      ),
    );
  }
}

class GameVersion {
  final String id;
  final String type;
  final String releaseTimeRaw;
  final DateTime releaseDate;

  GameVersion({
    required this.id,
    required this.type,
    required this.releaseTimeRaw,
    required this.releaseDate,
  });

  factory GameVersion.fromJson(Map<String, dynamic> json) {
    final raw = json['releaseTime'] as String;
    final dt = DateTime.parse(raw).toLocal();
    return GameVersion(
      id: json['id'] as String,
      type: json['type'] as String,
      releaseTimeRaw: raw,
      releaseDate: dt,
    );
  }

  String get formattedReleaseTime {
    return DateFormat('yyyy-MM-dd HH:mm').format(releaseDate);
  }
}

class VersionListView extends StatelessWidget {
  final VersionManifest manifest;

  const VersionListView({Key? key, required this.manifest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _LatestCard(
          releaseId: manifest.latestRelease,
          snapshotId: manifest.latestSnapshot,
        ),
        const SizedBox(height: 20),
        _ExpandableSection(
          title: '正式版本',
          icon: Icons.verified,
          items: manifest.releases,
        ),
        _ExpandableSection(
          title: '快照版本',
          icon: Icons.update,
          items: manifest.snapshots,
        ),
      ],
    );
  }
}

class _LatestCard extends StatelessWidget {
  final String releaseId;
  final String snapshotId;

  const _LatestCard({
    required this.releaseId,
    required this.snapshotId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('最新版本'),
            const SizedBox(height: 12),
            _LatestRow(
              icon: Icons.verified,
              label: '正式版',
              value: releaseId,
            ),
            const SizedBox(height: 8),
            _LatestRow(
              icon: Icons.update,
              label: '快照版',
              value: snapshotId,
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LatestRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(value),
      ],
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<GameVersion> items;

  const _ExpandableSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      maintainState: true,
      children: [
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final v = items[i];
              return ListTile(
                leading: title == "正式版本"
                    ? Image.asset("assets/images/games/release.png",
                        fit: BoxFit.contain)
                    : Image.asset("assets/images/games/snapshot.png",
                        fit: BoxFit.contain),
                title: Text(v.id),
                subtitle: Text('发布时间：${v.formattedReleaseTime}'),
                onTap: () {
                  showModalBottomSheet<dynamic>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => InstallGamePage(
                      gameVersion: v.id,
                      gameType: title,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
