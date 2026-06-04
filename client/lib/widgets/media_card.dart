import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../config/theme.dart';
import '../../models/media_item.dart';
import '../../providers/server_provider.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;

  const MediaCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final serverUrl = serverProvider.activeServer?.url;
    
    // 构建图片 URL
    String? imageUrl;
    if (serverUrl != null && item.imageTags?.containsKey('Primary') == true) {
      imageUrl = '$serverUrl/Items/${item.id}/Images/Primary?tag=${item.imageTags!['Primary']}';
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.goNamed('detail', pathParameters: {'mediaId': item.id});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 封面图区域
            Expanded(
              child: Stack(
                fill: true,
                children: [
                  // 网络图片或占位图
                  imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.cardColor,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                  // 渐变遮罩
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 信息区域
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  // 附加信息
                  Row(
                    children: [
                      if (item.productionYear != null) ...[
                        Text(
                          '${item.productionYear}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                      if (item.communityRating != null) ...[
                        const SizedBox(width: AppTheme.spacingS),
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: AppTheme.spacingXS),
                        Text(
                          item.communityRating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
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

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.cardColor,
      child: Center(
        child: Icon(
          Icons.movie,
          size: 48,
          color: AppTheme.textSecondary.withOpacity(0.5),
        ),
      ),
    );
  }
}
