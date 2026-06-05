import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 自定义缓存管理器 - 实现 Hills 级别的流畅图片加载
class CustomCacheManager {
  static const key = 'eboxCustomCache';
  
  static final instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 1000,
      repo: JsonFileRepo(),
      fileService: HttpFileService(),
    ),
  );
}

/// 优化的图片小部件 - 支持渐变加载和内存优化
class OptimizedImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double borderRadius;
  final bool fadeIn;

  const OptimizedImage({
    super.key,
    required this.url,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius = 12.0,
    this.fadeIn = true,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        cacheManager: CustomCacheManager.instance,
        maxWidthDiskCache: 1000,
        maxHeightDiskCache: 1000,
        memCacheWidth: (width * MediaQuery.of(context).devicePixelRatio).round(),
        memCacheHeight: (height * MediaQuery.of(context).devicePixelRatio).round(),
        fadeInDuration: fadeIn ? const Duration(milliseconds: 300) : Duration.zero,
        fadeOutDuration: fadeIn ? const Duration(milliseconds: 100) : Duration.zero,
        placeholder: (context, url) => placeholder ?? _buildGradientPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildPlaceholder(),
      ),
    );
  }

  Widget _buildGradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: 40,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          Icons.error_outline,
          size: 32,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}

/// 海报图片专用组件
class OptimizedPoster extends StatelessWidget {
  final String? url;
  final double width;
  final int index;

  const OptimizedPoster({
    super.key,
    required this.url,
    this.width = 200,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 1.5;
    
    return OptimizedImage(
      url: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: 12.0,
      fadeIn: index < 10, // 只在前 10 个项目添加渐变动画
    );
  }
}

/// 背景图片专用组件
class OptimizedBackdrop extends StatelessWidget {
  final String? url;

  const OptimizedBackdrop({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      url: url,
      fit: BoxFit.cover,
      borderRadius: 0,
      fadeIn: true,
    );
  }
}
