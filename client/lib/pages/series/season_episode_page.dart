import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/media_item.dart';
import '../../providers/media_provider.dart';
import '../../providers/server_provider.dart';

class SeasonEpisodePage extends StatefulWidget {
  final String seriesId;
  final String seasonId;
  final String seasonName;

  const SeasonEpisodePage({
    Key? key,
    required this.seriesId,
    required this.seasonId,
    required this.seasonName,
  }) : super(key: key);

  @override
  State<SeasonEpisodePage> createState() => _SeasonEpisodePageState();
}

class _SeasonEpisodePageState extends State<SeasonEpisodePage> {
  List<MediaItem> _episodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    setState(() => _isLoading = true);
    
    try {
      final mediaProvider = context.read<MediaProvider>();
      final apiClient = mediaProvider.apiClient;
      
      if (apiClient == null) {
        throw Exception('未连接到服务器');
      }
      
      // 获取该季的所有剧集
      final episodes = <MediaItem>[](
        // libraryId: widget.seasonId,
        // parentId: widget.seriesId,
        // mediaType: 'Episode',
      );
      
      if (mounted) {
        setState(() {
          _episodes = episodes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.seasonName),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: _episodes.isNotEmpty ? () => _playSeason() : null,
            tooltip: '播放全季',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _episodes.isEmpty
              ? const Center(child: Text('暂无剧集'))
              : ListView.builder(
                  itemCount: _episodes.length,
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  itemBuilder: (context, index) {
                    return _buildEpisodeCard(_episodes[index]);
                  },
                ),
    );
  }

  void _playSeason() {
    if (_episodes.isEmpty) return;
    // 播放第一集
    final firstEpisode = _episodes.first;
    context.push('/detail/${firstEpisode.id}');
  }

  Widget _buildEpisodeCard(MediaItem episode) {
    final serverProvider = context.watch<ServerProvider>();
    final serverUrl = serverProvider.activeServer?.url;
    
    String? imageUrl;
    if (serverUrl != null) {
      imageUrl = '$serverUrl/Items/${episode.id}/Images/Primary';
    }

    final isWatched = false; // episode.userData?.played
        final progress = 0.0;

    return Card(
      color: AppTheme.surfaceColor,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: () {
          context.push('/detail/${episode.id}');
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 剧照
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: Stack(
                  children: [
                    imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 200,
                            height: 113,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 200,
                            height: 113,
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            child: const Icon(Icons.play_circle_outline, size: 40),
                          ),
                    // 已观看标记
                    if (isWatched)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                      ),
                    // 播放按钮
                    Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 48,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      '${episode.episodeNumber ?? 0}. ${episode.name ?? '未命名'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    // 简介
                    if (episode.overview != null && episode.overview!.isNotEmpty)
                      Text(
                        episode.overview!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: AppTheme.spacingM),
                    // 元数据
                    Row(
                      children: [
                        if (episode.runTimeTicks != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Text(
                              episode.displayDuration,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (episode.communityRating != null) ...[
                          const SizedBox(width: AppTheme.spacingS),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                episode.communityRating!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    // 进度条
                    if (progress > 0 && progress < 0.99) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
