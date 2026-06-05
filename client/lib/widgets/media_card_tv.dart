import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/media_item.dart';

/// TV 优化的媒体卡片
/// 更适合遥控器导航的大尺寸卡片
class MediaCardTv extends StatefulWidget {
  final MediaItem item;
  final double width;
  final double height;

  const MediaCardTv({
    Key? key,
    required this.item,
    this.width = 200,
    this.height = 300,
  }) : super(key: key);

  @override
  State<MediaCardTv> createState() => _MediaCardTvState();
}

class _MediaCardTvState extends State<MediaCardTv> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        setState(() => _isFocused = focused);
      },
      child: GestureDetector(
        onTap: () {
          context.push('/detail/${widget.item.id}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : null,
          ),
          transform: _isFocused
              ? Matrix4.identity()..scale(1.1)
              : Matrix4.identity(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Stack(
              children: [
                // 海报
                AspectRatio(
                  aspectRatio: widget.width / widget.height,
                  child: CachedNetworkImage(
                    imageUrl: _getImageUrl(context),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      child: const Icon(Icons.movie, size: 40),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      child: const Icon(Icons.error, size: 40),
                    ),
                  ),
                ),
                // 渐变遮罩
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                // 标题
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Text(
                    widget.item.name ?? '未命名',
                    style: TextStyle(
                      fontSize: _isFocused ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                // 已观看标记
                if (widget.item.userData?.played == true)
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getImageUrl(BuildContext context) {
    final serverProvider = context.read<MediaProvider>();
    final serverUrl = serverProvider.server?.url;
    
    if (serverUrl != null && widget.item.imageTags?.isNotEmpty == true) {
      final tag = widget.item.imageTags!.values.first;
      return '$serverUrl/Items/${widget.item.id}/Images/Primary?tag=$tag';
    }
    
    return 'https://via.placeholder.com/${widget.width}x${widget.height}';
  }
}
