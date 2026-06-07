import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/emby_api_service.dart';
import '../../providers/server_provider.dart';
import 'package:provider/provider.dart';

class MediaDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const MediaDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _details;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);

    try {
      final server = context.read<ServerProvider>().activeServer;
      if (server == null) {
        setState(() {
          _error = '未连接服务器';
          _isLoading = false;
        });
        return;
      }

      final api = EmbyApiService(
        baseUrl: server.url,
        apiKey: server.apiKey,
        userId: '1',
      );

      final itemId = widget.item['Id'] as String;
      final details = await api.getItem(itemId);

      setState(() {
        _details = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _details ?? widget.item;
    final name = data['Name'] as String? ?? '未知';
    final overview = data['Overview'] as String?;
    final year = data['ProductionYear'];
    final rating = data['CommunityRating'];
    final runtime = data['RunTimeTicks'];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(data, name),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetadata(year, rating, runtime),
                  const SizedBox(height: 24),
                  _buildPlayButton(data),
                  const SizedBox(height: 32),
                  if (overview != null && overview.isNotEmpty) ...[
                    const Text(
                      '简介',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      overview,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[300],
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Map<String, dynamic> data, String name) {
    final backdropUrl = _getBackdropUrl(data['Id']);

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (backdropUrl.isNotEmpty)
              Image.network(
                backdropUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildGradientBackground();
                },
              )
            else
              _buildGradientBackground(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0A0A0A).withOpacity(0.8),
                    const Color(0xFF0A0A0A),
                  ],
                  stops: const [0.5, 0.9, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
        ),
      ),
    );
  }

  Widget _buildMetadata(dynamic year, dynamic rating, dynamic runtime) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (year != null)
          _buildChip(year.toString()),
        if (rating != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        if (runtime != null)
          _buildChip(_formatRuntime(runtime)),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  String _formatRuntime(int ticks) {
    final minutes = (ticks / 10000000 / 60).round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}小时${mins > 0 ? '$mins 分钟' : ''}';
    }
    return '${minutes}分钟';
  }

  Widget _buildPlayButton(Map<String, dynamic> data) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _playMedia(data),
        icon: const Icon(Icons.play_arrow, size: 28, color: Color(0xFF6C5CE7)),
        label: const Text(
          '播放',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C5CE7),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _playMedia(Map<String, dynamic> data) {
    final server = context.read<ServerProvider>().activeServer;
    if (server == null) return;

    final itemId = data['Id'] as String;
    final name = data['Name'] as String? ?? '视频';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('准备播放：$name'),
        backgroundColor: const Color(0xFF6C5CE7),
      ),
    );

    Navigator.of(context).pushNamed(
      '/player',
      arguments: {
        'itemId': itemId,
        'title': name,
      },
    );
  }

  String _getBackdropUrl(String itemId) {
    final server = context.read<ServerProvider>().activeServer;
    if (server == null) return '';
    return '${server.url}/Items/$itemId/Images/Backdrop?api_key=${server.apiKey}';
  }
}
