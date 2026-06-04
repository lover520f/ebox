import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/media_provider.dart';
import '../../providers/server_provider.dart';
import '../../models/media_item.dart';
import '../../widgets/media_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart' as custom_widgets;

class LibraryPage extends StatefulWidget {
  final String libraryId;

  const LibraryPage({super.key, required this.libraryId});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _gridColumns = 4;
  String _sortBy = 'SortName';
  String _viewMode = 'grid'; // grid or list

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    context.read<MediaProvider>().loadItems(widget.libraryId);
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();
    final items = mediaProvider.itemsByLibrary[widget.libraryId] ?? [];
    final isLoading = mediaProvider.isLoading;
    final error = mediaProvider.error;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('媒体库'),
        actions: [
          // 搜索
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 搜索功能
            },
            tooltip: '搜索',
          ),
          // 视图切换
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'grid') {
                setState(() => _viewMode = 'grid');
              } else if (value == 'list') {
                setState(() => _viewMode = 'list');
              } else if (value.startsWith('column')) {
                setState(() {
                  _gridColumns = int.parse(value.substring(6));
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'grid',
                child: ListTile(
                  leading: Icon(Icons.grid_view),
                  title: Text('网格视图'),
                ),
              ),
              const PopupMenuItem(
                value: 'list',
                child: ListTile(
                  leading: Icon(Icons.view_list),
                  title: Text('列表视图'),
                ),
              ),
              const PopupMenuDivider(),
              _buildColumnMenuItem(2),
              _buildColumnMenuItem(3),
              _buildColumnMenuItem(4),
              _buildColumnMenuItem(5),
              _buildColumnMenuItem(6),
            ],
          ),
          // 排序
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadItems();
            },
            itemBuilder: (context) => [
              _buildSortMenuItem('SortName', '名称'),
              _buildSortMenuItem('ProductionYear', '年份'),
              _buildSortMenuItem('CommunityRating', '评分'),
              _buildSortMenuItem('DateCreated', '添加时间'),
            ],
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : error != null
              ? _buildErrorState(error)
              : items.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(items),
    );
  }

  Widget _buildLoadingState() {
    if (_viewMode == 'list') {
      return ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => const ListItemLoadingWidget(),
      );
    } else {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridColumns,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
        ),
        itemCount: _gridColumns * 3,
        itemBuilder: (context, index) => const PosterLoadingWidget(),
      );
    }
  }

  Widget _buildErrorState(String error) {
    return custom_widgets.ErrorWidget(
      message: '加载失败',
      hint: error,
      icon: Icons.cloud_off_outlined,
      onRetry: _loadItems,
    );
  }

  Widget _buildContent(List<MediaItem> items) {
    if (_viewMode == 'list') {
      return ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildListItem(item);
        },
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridColumns,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return MediaCard(item: item);
        },
      );
    }
  }

  Widget _buildListItem(MediaItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: () {
          context.goNamed('detail', pathParameters: {'mediaId': item.id});
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              // 封面图
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(Icons.movie, size: 40, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: AppTheme.spacingM),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Row(
                      children: [
                        if (item.productionYear != null) ...[
                          Text(
                            '${item.productionYear}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                        ],
                        if (item.communityRating != null) ...[
                          const Icon(Icons.star, size: 16, color: AppTheme.warningColor),
                          const SizedBox(width: AppTheme.spacingXS),
                          Text(
                            '${item.communityRating}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.overview != null) ...[
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        item.overview!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppTheme.spacingL),
          const Text(
            '暂无媒体内容',
            style: TextStyle(
              fontSize: 20,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildColumnMenuItem(int columns) {
    return PopupMenuItem(
      value: 'column$columns',
      child: ListTile(
        leading: Icon(Icons.view_module),
        title: Text('$columns 列'),
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: ListTile(
        leading: Icon(_sortBy == value ? Icons.check : Icons.sort),
        title: Text(label),
      ),
    );
  }
}
