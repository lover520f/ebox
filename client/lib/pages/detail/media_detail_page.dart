import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/media_item.dart';
import '../../providers/media_provider.dart';
import '../../providers/server_provider.dart';
import '../../services/emby_api_client.dart';

class MediaDetailPage extends StatefulWidget {
  final String itemId;
  const MediaDetailPage({Key? key, required this.itemId}) : super(key: key);

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  MediaItem? _mediaItem;
  bool _isLoading = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadMediaDetail();
  }

  Future<void> _loadMediaDetail() async {
    setState(() => _isLoading = true);
    final mediaProvider = context.read<MediaProvider>();
    final apiClient = mediaProvider.apiClient;

    if (apiClient == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('未连接到服务器')));
      }
      return;
    }

    try {
      _mediaItem = await apiClient.getItemDetail(widget.itemId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('加载失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _playMedia() async {
    if (_mediaItem == null) return;
    final apiClient = context.read<EmbyApiClient>();
    setState(() => _isPlaying = true);

    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('正在获取播放地址...')]),
        duration: Duration(seconds: 30),
      ));
      final videoUrl = await apiClient.getPlaybackUrl(_mediaItem!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.push('/player/${_mediaItem!.id}', extra: {'videoUrl': videoUrl, 'title': _mediaItem!.name});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('播放失败：$e')));
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_mediaItem == null) return Scaffold(appBar: AppBar(title: const Text('媒体详情')), body: const Center(child: Text('加载失败')));

    final serverProvider = context.watch<ServerProvider>();
    final serverUrl = serverProvider.activeServer?.url;
    String? backdropUrl;
    if (serverUrl != null && _mediaItem!.imageTags?.containsKey('Backdrop') == true) {
      backdropUrl = '$serverUrl/Items/${_mediaItem!.id}/Images/Backdrop?tag=${_mediaItem!.imageTags!['Backdrop']}';
    }

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          expandedHeight: 400, pinned: true, stretch: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: [
              if (backdropUrl != null)
                CachedNetworkImage(imageUrl: backdropUrl, fit: BoxFit.cover,
                  placeholder: (c, u) => _buildPlaceholder(),
                  errorWidget: (c, u, e) => _buildPlaceholder(),
                )
              else
                _buildPlaceholder(),
              Container(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.backgroundColor.withOpacity(0.9), AppTheme.backgroundColor],
                  stops: const [0.5, 0.8, 1.0],
                ),
              )),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_mediaItem!.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppTheme.spacingM),
              Wrap(spacing: AppTheme.spacingM, runSpacing: AppTheme.spacingS, children: [
                if (_mediaItem!.productionYear != null) _buildMetadataChip(Icons.calendar_today, '${_mediaItem!.productionYear}'),
                if (_mediaItem!.communityRating != null) _buildMetadataChip(Icons.star, _mediaItem!.communityRating!.toStringAsFixed(1), color: AppTheme.warningColor),
                if (_mediaItem!.runTimeTicks != null) _buildMetadataChip(Icons.access_time, _mediaItem!.displayDuration),
              ]),
              const SizedBox(height: AppTheme.spacingL),
              SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isPlaying ? null : _playMedia,
                  icon: _isPlaying ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Icon(Icons.play_arrow, size: 28),
                  label: Text(_isPlaying ? '获取播放地址中...' : '播放', style: const TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM)),
                ),
              ),
              if (_mediaItem!.overview != null && _mediaItem!.overview!.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingL),
                const Text('剧情简介', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppTheme.spacingM),
                Text(_mediaItem!.overview!, style: const TextStyle(fontSize: 16, height: 1.6)),
              ],
              const SizedBox(height: AppTheme.spacingXL),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildPlaceholder() => Container(decoration: BoxDecoration(
    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [AppTheme.primaryColor.withOpacity(0.3), AppTheme.backgroundColor],
    ),
  ), child: const Icon(Icons.movie, size: 100, color: Colors.white24));

  Widget _buildMetadataChip(IconData icon, String label, {Color? color}) => Chip(
    avatar: Icon(icon, size: 16, color: color ?? Colors.white),
    label: Text(label, style: const TextStyle(color: Colors.white)),
    backgroundColor: AppTheme.surfaceColor.withOpacity(0.8),
  );
}
