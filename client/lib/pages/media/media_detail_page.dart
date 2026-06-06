import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/media_item.dart';
import '../../providers/media_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/media_card.dart';

class MediaDetailPage extends StatefulWidget {
  final MediaItem item;
  
  const MediaDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  bool _showFullOverview = false;
  List<MediaItem> _episodes = [];
  List<MediaItem> _seasons = [];
  List<MediaItem> _similarItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    try {
      final mediaProvider = context.read<MediaProvider>();
      final apiClient = mediaProvider.apiClient;
      
      if (apiClient != null) {
        if (widget.item.type == 'Series') {
          final results = await Future.wait([
            apiClient.getSeasons(widget.item.id),
            apiClient.getSimilarItems(widget.item.id, limit: 10),
          ]);
          setState(() {
            _seasons = results[0];
            _similarItems = results[1];
            _isLoading = false;
          });
        } else if (widget.item.type == 'Season') {
          _episodes = await apiClient.getEpisodes(widget.item.seriesId ?? widget.item.id);
          setState(() => _isLoading = false);
        } else {
          _similarItems = await apiClient.getSimilarItems(widget.item.id, limit: 10);
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('加载详情失败：$e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildBackdropHeader(),
                SliverToBoxAdapter(child: _buildContent()),
              ],
            ),
    );
  }

  Widget _buildBackdropHeader() {
    final hasBackdrop = widget.item.backdropImageTags?.isNotEmpty ?? false;
    
    return SliverAppBar(
      expandedHeight: 500,
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
            if (hasBackdrop)
              Image.network(
                widget.item.getBackdropUrl(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildGradientBackground(),
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
                    const Color(0xFF0A0A0A).withOpacity(0.6),
                    const Color(0xFF0A0A0A),
                  ],
                  stops: const [0.5, 0.8, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.item.type != 'Episode') ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.item.getPrimaryImageUrl(),
                            width: 140,
                            height: 210,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.name,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMetadata(),
                            const SizedBox(height: 24),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C5CE7),
            const Color(0xFF00CEC9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 140,
      height: 210,
      color: Colors.grey[800],
      child: Icon(Icons.movie, size: 60, color: Colors.grey[600]),
    );
  }

  Widget _buildMetadata() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (widget.item.communityRating != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                widget.item.communityRating!.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        if (widget.item.productionYear != null)
          _buildMetadataChip(widget.item.productionYear.toString()),
        if (widget.item.runtime != null)
          _buildMetadataChip(_formatRuntime(widget.item.runtime!)),
      ],
    );
  }

  Widget _buildMetadataChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _playItem,
          icon: const Icon(Icons.play_arrow, size: 28, color: Color(0xFF6C5CE7)),
          label: Text(
            _shouldShowResume() ? '继续观看' : '播放',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C5CE7),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  bool _shouldShowResume() {
    return widget.item.userData?.playbackPositionTicks != null &&
           widget.item.userData!.playbackPositionTicks! > 0;
  }

  void _playItem() {
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.playMedia(widget.item);
    context.push('/player', extra: {
      'item': widget.item,
      'playPosition': widget.item.userData?.playbackPositionTicks ?? 0,
    });
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.item.type == 'Series' && _seasons.isNotEmpty) ...[
            _buildSeasonsSection(),
            const SizedBox(height: 40),
          ],
          if (widget.item.type == 'Season' && _episodes.isNotEmpty) ...[
            _buildEpisodesSection(),
            const SizedBox(height: 40),
          ],
          _buildOverviewSection(),
          if (_similarItems.isNotEmpty) ...[
            const SizedBox(height: 40),
            _buildSimilarSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    final overview = widget.item.overview;
    if (overview == null || overview.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('简介', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Text(
          overview,
          style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[300]),
          maxLines: _showFullOverview ? null : 4,
          overflow: _showFullOverview ? null : TextOverflow.ellipsis,
        ),
        if (!_showFullOverview)
          TextButton(
            onPressed: () => setState(() => _showFullOverview = true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF6C5CE7)),
            child: const Text('展开全文'),
          ),
      ],
    );
  }

  Widget _buildSeasonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('剧集', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _seasons.map((season) {
            return InkWell(
              onTap: () => context.push('/media/${season.id}', extra: season),
              child: Container(
                width: 140,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.tv_rounded, size: 48, color: const Color(0xFF6C5CE7).withOpacity(0.8)),
                    const SizedBox(height: 12),
                    Text(
                      season.name ?? '未知季',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEpisodesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('剧集列表', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _episodes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildEpisodeTile(_episodes[index]),
        ),
      ],
    );
  }

  Widget _buildEpisodeTile(MediaItem episode) {
    return InkWell(
      onTap: () {
        context.read<PlayerProvider>().playMedia(episode);
        context.push('/player', extra: {
          'item': episode,
          'playPosition': episode.userData?.playbackPositionTicks ?? 0,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                episode.getPrimaryImageUrl(),
                width: 160,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 160,
                  height: 90,
                  color: Colors.grey[800],
                  child: Icon(Icons.movie, size: 40, color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.name ?? '未知剧集',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (episode.runtime != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatRuntime(episode.runtime!),
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.play_circle_outline, color: const Color(0xFF6C5CE7), size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('类似推荐', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _similarItems.length,
            itemBuilder: (context, index) => MediaCard(item: _similarItems[index], width: 200),
          ),
        ),
      ],
    );
  }
}
