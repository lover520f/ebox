import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/media_item.dart';
import '../providers/player_provider.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final double? width;
  final VoidCallback? onLongPress;

  const MediaCard({
    Key? key,
    required this.item,
    this.width,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? 200;
    final cardHeight = width != null ? (width! * 1.5) : 300;
    final showResume = item.userData?.playbackPositionTicks != null &&
                       item.userData!.playbackPositionTicks! > 0 &&
                       item.type != 'Series';

    return GestureDetector(
      onTap: () {
        context.push('/media/${item.id}', extra: item);
      },
      onDoubleTap: () {
        final playerProvider = context.read<PlayerProvider>();
        playerProvider.playMedia(item);
        context.push('/player', extra: {
          'item': item,
          'playPosition': item.userData?.playbackPositionTicks ?? 0,
        });
      },
      onLongPress: onLongPress,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Image.network(
                          item.getPrimaryImageUrl(),
                          width: cardWidth,
                          height: cardHeight,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: cardWidth,
                              height: cardHeight,
                              color: const Color(0xFF141414),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalDuration != null
                                      ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                      : null,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF6C5CE7),
                                  ),
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: cardWidth,
                              height: cardHeight,
                              color: const Color(0xFF141414),
                              child: Icon(
                                _getIconForType(item.type),
                                size: 60,
                                color: Colors.grey[700],
                              ),
                            );
                          },
                        ),
                        if (showResume)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: _buildResumeProgressBar(cardWidth),
                          ),
                        if (item.type == 'Movie' || item.type == 'Series')
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.type == 'Movie' ? '电影' : '剧集',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF141414),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (item.communityRating != null) ...[
                              const Icon(Icons.star, color: Colors.amber, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                item.communityRating!.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (item.productionYear != null)
                              Text(
                                item.productionYear.toString(),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.push('/media/${item.id}', extra: item);
                  },
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'Movie':
        return Icons.movie;
      case 'Series':
        return Icons.tv;
      case 'Episode':
        return Icons.play_circle_outline;
      case 'Music':
        return Icons.music_note;
      case 'Book':
        return Icons.book;
      default:
        return Icons.video_library;
    }
  }

  Widget _buildResumeProgressBar(double width) {
    double progress = 0.0;
    if (item.userData?.playbackPositionTicks != null &&
        item.userData?.runtimeTicks != null &&
        item.userData!.runtimeTicks! > 0) {
      progress = item.userData!.playbackPositionTicks! /
                 item.userData!.runtimeTicks!;
      progress = progress.clamp(0.0, 1.0);
    }

    return Container(
      height: 4,
      color: Colors.black.withOpacity(0.5),
      child: FractionallySizedBox(
        widthFactor: progress,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6C5CE7),
                Color(0xFF00CEC9),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
