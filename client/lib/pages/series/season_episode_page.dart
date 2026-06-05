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
      
      if (apiClient != null) {
        final episodes = await apiClient.getSeasons(widget.seriesId, widget.seasonId);
        if (mounted) {
          setState(() {
            _episodes = episodes;
            _isLoading = false;
          });
        }
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
                );
  }

  Widget _buildEpisodeCard(MediaItem episode) {
    final serverProvider = context.watch<ServerProvider>();
    final serverUrl = serverProvider.activeServer?.url;
    
    String? imageUrl;
    if (serverUrl != null && episode.imageTags?.isNotEmpty == true) {
      imageUrl = '$serverUrl/Items/${episode.id}/Images/Primary';
    }

    return Card(
      color: AppTheme.surfaceColor,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: () {
          context.push('/detail/${episode.id}');
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 160,
                        height: 90,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 160,
                        height: 90,
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        child: const Icon(Icons.play_circle_outline),
                      ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${episode.indexNumber ?? 0}. ${episode.name ?? '未命名'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    if (episode.overview != null && episode.overview!.isNotEmpty)
                      Text(
                        episode.overview!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
