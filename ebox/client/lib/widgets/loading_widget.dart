import 'package:flutter/material.dart';

import '../config/theme.dart';

/// 加载动画组件 - Shimmer 骨架屏效果
class LoadingWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const LoadingWidget({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMedium),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                0.0,
                0.5 + (_animation.value * 0.25),
                1.0,
              ],
              colors: const [
                AppTheme.cardColor,
                AppTheme.cardHoverColor,
                AppTheme.cardColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 海报卡片加载占位符
class PosterLoadingWidget extends StatelessWidget {
  const PosterLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 封面图占位
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMedium)),
            ),
          ),
        ),
        // 标题占位
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoadingWidget(height: 14),
              const SizedBox(height: AppTheme.spacingXS),
              LoadingWidget(width: 80, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

/// 列表项加载占位符
class ListItemLoadingWidget extends StatelessWidget {
  const ListItemLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          // 封面占位
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          // 信息占位
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingWidget(width: 200, height: 18),
                const SizedBox(height: AppTheme.spacingS),
                LoadingWidget(width: 100, height: 14),
                const SizedBox(height: AppTheme.spacingS),
                LoadingWidget(width: 180, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 详情页头部加载占位符
class DetailHeaderLoadingWidget extends StatelessWidget {
  const DetailHeaderLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppTheme.radiusXLarge)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
