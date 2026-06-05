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

class LibraryPageOptimized extends StatefulWidget {
  final String libraryId;

  const LibraryPageOptimized({super.key, required this.libraryId});

  @override
  State<LibraryPageOptimized> createState() => _LibraryPageOptimizedState();
}

class _LibraryPageOptimizedState extends State<LibraryPageOptimized> {
  int _gridColumns = 4;
  String _sortBy = 'SortName';
  String _viewMode = 'grid';

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
          onPressed: () => context.pop(),
        ),
        title: const Text('媒体库'),
        actions: [
          _buildViewSwitcher(),
          _buildSortMenu(),
        ],
      ),
      body: _buildBody(items, isLoading, error),
    );
  }

  Widget _buildBody(List<MediaItem> items, bool isLoading, String? error) {
    if (isLoading) return _buildLoadingState();
    if (error != null) return _buildErrorState(error);
    if (items.isEmpty) return _buildEmptyState();
    return _buildContent(items);
  }

  Widget _buildContent(List<MediaItem> items) {
    if (_viewMode == 'list') {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildListItem(items[index]),
        cacheExtent: 1000, // 预加载缓存
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridColumns,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => MediaCard(
          item: items[index],
          index: index,
          key: ValueKey(items[index].id), // 添加 key 提高性能
        ),
        cacheExtent: 1500, // 增加预加载距离
        addAutomaticKeepAlives: true, // 保持 offscreen 项目
        addRepaintBoundaries: false, // 关闭重绘边界提高性能
      );
    }
  }

  Widget _buildListItem(MediaItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.goNamed('detail', pathParameters: {'mediaId': item.id}),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.movie, size: 40, color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (item.productionYear != null)
                        Text('${item.productionYear}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      if (item.communityRating != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${item.communityRating}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return _viewMode == 'list'
        ? ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => const ListItemLoadingWidget(),
          )
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridColumns,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _gridColumns * 3,
            itemBuilder: (context, index) => const PosterLoadingWidget(),
          );
  }

  Widget _buildErrorState(String error) {
    return custom_widgets.ErrorWidget(
      message: '加载失败',
      hint: error,
      icon: Icons.cloud_off_outlined,
      onRetry: _loadItems,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 24),
          const Text('暂无媒体内容', style: TextStyle(fontSize: 20, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildViewSwitcher() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          if (value == 'grid') _viewMode = 'grid';
          else if (value == 'list') _viewMode = 'list';
          else if (value.startsWith('column')) _gridColumns = int.parse(value.substring(6));
        });
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'grid', child: ListTile(leading: Icon(Icons.grid_view), title: Text('网格视图'))),
        const PopupMenuItem(value: 'list', child: ListTile(leading: Icon(Icons.view_list), title: Text('列表视图'))),
        const PopupMenuDivider(),
        _buildColumnMenuItem(2),
        _buildColumnMenuItem(3),
        _buildColumnMenuItem(4),
        _buildColumnMenuItem(5),
        _buildColumnMenuItem(6),
      ],
    );
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _sortBy = value;
          _loadItems();
        });
      },
      itemBuilder: (context) => [
        _buildSortMenuItem('SortName', '名称'),
        _buildSortMenuItem('ProductionYear', '年份'),
        _buildSortMenuItem('CommunityRating', '评分'),
        _buildSortMenuItem('DateCreated', '添加时间'),
      ],
    );
  }

  PopupMenuItem<String> _buildColumnMenuItem(int columns) {
    return PopupMenuItem(
      value: 'column$columns',
      child: ListTile(
        leading: Icon(_gridColumns == columns ? Icons.check : Icons.view_module),
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
