import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/media_item.dart';
import '../../providers/server_provider.dart';

class SeasonEpisodePage extends StatefulWidget {
  final String seriesId;
  final String seasonId;
  final String seasonName;
  const SeasonEpisodePage({Key? key, required this.seriesId, required this.seasonId, required this.seasonName}) : super(key: key);

  @override
  State<SeasonEpisodePage> createState() => _SeasonEpisodePageState();
}

class _SeasonEpisodePageState extends State<SeasonEpisodePage> {
  List<MediaItem> _episodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // TODO: 加载剧集数据
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: Text(widget.seasonName), backgroundColor: AppTheme.backgroundColor),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _episodes.isEmpty
              ? const Center(child: Text('暂无剧集'))
              : ListView.builder(
                  itemCount: _episodes.length,
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  itemBuilder: (context, index) => _buildEpisodeCard(_episodes[index]),
                ),
    );
  }

  Widget _buildEpisodeCard(MediaItem episode) {
    final serverProvider = context.watch<ServerProvider>();
    final serverUrl = serverProvider.activeServer?.url;
    String? imageUrl = serverUrl != null ? '$serverUrl/Items/${episode.id}/Images/Primary' : null;

    return Card(
      color: AppTheme.surfaceColor,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: () => context.push('/detail/${episode.id}'),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: imageUrl != null
                    ? CachedNetworkImage(imageUrl: imageUrl, width: 160, height: 90, fit: BoxFit.cover)
                    : Container(width: 160, height: 90, color: AppTheme.primaryColor.withOpacity(0.2), child: const Icon(Icons.play_circle_outline)),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${episode.episodeNumber ?? 0}. ${episode.name ?? '未命名'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    if (episode.overview != null && episode.overview!.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingS),
                      Text(episode.overview!, style: TextStyle(fontSize: 13, color: Colors.grey[400], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
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
