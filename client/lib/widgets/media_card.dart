import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../config/theme.dart';
import '../../models/media_item.dart';
import '../../providers/server_provider.dart';
import '../../pages/player/video_player_page.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final int index;
  final double width;
  final VoidCallback? onTap;

  const MediaCard({
    super.key,
    required this.item,
    this.index = 0,
    this.width = 200,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final serverProvider = Provider.of<ServerProvider>(context, listen: false);
    final serverUrl = serverProvider.activeServer?.url;
    
    // 构建图片 URL
    String? imageUrl;
    if (serverUrl != null && item.imageTags?.containsKey('Primary') == true) {
      imageUrl = '$serverUrl/Items/${item.id}/Images/Primary?tag=${item.imageTags!['Primary']}';
    }

    // 计算内存缓存尺寸
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final memCacheWidth = (width * devicePixelRatio).round();
    final memCacheHeight = (width * 1.5 * devicePixelRatio).round();

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer, // 使用 saveLayer 提高性能
      child: InkWell(
        onTap: onTap ?? () {
          context.goNamed('detail', pathParameters: {'mediaId': item.id});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 封面图区域 - 使用懒加载和智能缓存
            Expanded(
              child: Stack(
                children: [
                  // 使用 CachedNetworkImage 的优化配置
                  if (imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      maxWidthDiskCache: 500,
                      maxHeightDiskCache: 750,
                      memCacheWidth: memCacheWidth,
                      memCacheHeight: memCacheHeight,
                      fadeInDuration: index < 6 ? const Duration(milliseconds: 300) : Duration.zero,
                      fadeOutDuration: const Duration(milliseconds: 50),
                      placeholder: (context, url) => _buildShimmerPlaceholder(),
                      errorWidget: (context, url, error) => _buildColoredPlaceholder(),
                    )
                  else
                    _buildColoredPlaceholder(),
                  // 渐变遮罩 - 提升文字可读性
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                  // 播放按钮 - 带悬浮动画
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _PlayButton(
                      itemId: item.id,
                      serverId: serverProvider.activeServer?.id ?? '',
                    ),
                  ),
                ],
              ),
            ),
            // 信息区域
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题 - 限制 2 行
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // 附加信息
                  Row(
                    children: [
                      if (item.productionYear != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.productionYear}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                      if (item.communityRating != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 10,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                item.communityRating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // 骨架屏占位图
  Widget _buildShimmerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
      ),
    );
  }

  // 纯色占位图
  Widget _buildColoredPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
      ),
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: 40,
          color: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }
}

// 独立的播放按钮组件 - 减少重绘
class _PlayButton extends StatefulWidget {
  final String itemId;
  final String serverId;

  const _PlayButton({
    required this.itemId,
    required this.serverId,
  });

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        _controller.reverse();
        setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: () {
          context.goNamed('player', queryParameters: {
            'itemId': widget.itemId,
            'serverId': widget.serverId,
          });
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isHovered 
                  ? const Color(0xFF6366F1).withOpacity(1.0)
                  : const Color(0xFF6366F1).withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
