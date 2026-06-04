import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../config/theme.dart';
import '../../models/media_item.dart';
import '../../providers/media_provider.dart';
import '../../providers/server_provider.dart';

class MediaDetailPage extends StatefulWidget {
  final String mediaId;

  const MediaDetailPage({super.key, required this.mediaId});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  MediaItem? _mediaItem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMediaDetail();
  }

  void _loadMediaDetail() async {
    setState(() => _isLoading = true);
    
    final mediaProvider = context.read<MediaProvider>();
    try {
      _mediaItem = await mediaProvider.apiClient.getItemDetail(widget.mediaId);
    } catch (e) {
      // 错误处理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败：$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_mediaItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('媒体详情')),
        body: const Center(child: Text('加载失败')),
      );
    }

    final serverProvider = context.watch<ServerProvider>();
    final serverUrl = serverProvider.activeServer?.url;
    
    String? backdropUrl;
    if (serverUrl != null && _mediaItem!.imageTags?.containsKey('Backdrop') == true) {
      backdropUrl = '$serverUrl/Items/${_mediaItem!.id}/Images/Backdrop?tag=${_mediaItem!.imageTags!['Backdrop']}';
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 背景海报
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fill: true,
                children: [
                  // 使用网络图片
                  if (backdropUrl != null)
                    CachedNetworkImage(
                      imageUrl: backdropUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.3),
                              AppTheme.backgroundColor,
                            ],
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),
                  // 渐变遮罩
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.backgroundColor.withOpacity(0.9),
                          AppTheme.backgroundColor,
                        ],
                        stops: const [0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: 更多操作
                },
              ),
            ],
          ),
          
          // 内容区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和元数据
                  Text(
                    _mediaItem!.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // 元数据行
                  Wrap(
                    spacing: AppTheme.spacingM,
                    runSpacing: AppTheme.spacingS,
                    children: [
                      if (_mediaItem!.productionYear != null) ...[
                        _buildMetadataChip(
                          Icons.calendar_today,
                          '${_mediaItem!.productionYear}',
                        ),
                      ],
                      if (_mediaItem!.communityRating != null) ...[
                        _buildMetadataChip(
                          Icons.star,
                          _mediaItem!.communityRating!.toStringAsFixed(1),
                          color: AppTheme.warningColor,
                        ),
                      ],
                      if (_mediaItem!.runTimeTicks != null) ...[
                        _buildMetadataChip(
                          Icons.access_time,
                          _mediaItem!.displayDuration,
                        ),
                      ],
                      if (_mediaItem!.officialRating != null) ...[
                        _buildMetadataChip(
                          Icons.info,
                          _mediaItem!.officialRating!,
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // 播放按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 跳转到播放器
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('播放器功能开发中...')),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text(
                        '播放',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // 剧情简介
                  if (_mediaItem!.overview != null) ...[
                    const Text(
                      '剧情简介',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      _mediaItem!.overview!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                  ],
                  
                  // 类型标签
                  if (_mediaItem!.genres != null && _mediaItem!.genres!.isNotEmpty) ...[
                    const Text(
                      '类型',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Wrap(
                      spacing: AppTheme.spacingS,
                      runSpacing: AppTheme.spacingS,
                      children: _mediaItem!.genres!.map((genre) {
                        return Chip(
                          label: Text(genre),
                          backgroundColor: AppTheme.cardColor,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                  ],
                  
                  // 演职员表
                  if (_mediaItem!.people != null && _mediaItem!.people!.isNotEmpty) ...[
                    const Text(
                      '演职员',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _mediaItem!.people!.length,
                        itemBuilder: (context, index) {
                          final person = _mediaItem!.people![index];
                          return _buildPersonCard(person);
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color ?? AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(dynamic person) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppTheme.spacingM),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(Icons.person, size: 40, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            person.name,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (person.role != null) ...[
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              person.role,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Movie':
        return Icons.movie;
      case 'Series':
        return Icons.tv;
      case 'Episode':
        return Icons.slideshow;
      default:
        return Icons.theater_comedy;
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withOpacity(0.3),
            AppTheme.backgroundColor,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getIconForType(_mediaItem!.type),
          size: 120,
          color: AppTheme.textSecondary.withOpacity(0.3),
        ),
      ),
    );
  }
}
