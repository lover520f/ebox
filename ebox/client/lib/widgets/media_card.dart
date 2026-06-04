import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/media_item.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;

  const MediaCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
                  // 背景色
                  Container(
                    color: AppTheme.cardColor,
                  ),
                  // 封面图 (使用占位图，实际使用时替换为网络图片)
                  Center(
                    child: Icon(
                      _getIconForType(item.type),
                      size: 48,
                      color: AppTheme.textSecondary.withOpacity(0.5),
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

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Movie':
        return Icons.movie;
      case 'Series':
        return Icons.tv;
      case 'Episode':
        return Icons.slideshow;
      case 'Season':
        return Icons.folder;
      case 'Audio':
        return Icons.music_note;
      case 'Book':
        return Icons.book;
      default:
        return Icons.theater_comedy;
    }
  }
}
