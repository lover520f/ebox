import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/watch_history_service.dart';
import '../../providers/server_provider.dart';

class WatchHistoryPage extends StatefulWidget {
  const WatchHistoryPage({Key? key}) : super(key: key);

  @override
  State<WatchHistoryPage> createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends State<WatchHistoryPage> {
  bool _isLoading = true;
  List<WatchHistoryRecord> _records = [];
  String _filterType = 'all'; // all, movie, tvshow

  final WatchHistoryService _historyService = WatchHistoryService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      await _historyService.init();
      final all = _historyService.getAll(limit: 100);
      
      if (_filterType != 'all') {
        setState(() {
          _records = all.where((r) => 
            r.type.toLowerCase().contains(_filterType)
          ).toList();
        });
      } else {
        setState(() => _records = all);
      }
    } catch (e) {
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('观看历史'),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          if (_records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _confirmClear(),
              tooltip: '清空历史',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // 筛选栏
                    _buildFilterBar(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _records.length,
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        itemBuilder: (context, index) {
                          final record = _records[index];
                          return _buildHistoryCard(record);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      child: Row(
        children: [
          _buildFilterChip('全部', 'all'),
          const SizedBox(width: AppTheme.spacingS),
          _buildFilterChip('电影', 'movie'),
          const SizedBox(width: AppTheme.spacingS),
          _buildFilterChip('剧集', 'tvshow'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = _filterType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterType = type);
        _loadHistory();
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryColor.withOpacity(0.3),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildHistoryCard(WatchHistoryRecord record) {
    final serverProvider = context.watch<ServerProvider>();
    final serverUrl = serverProvider.activeServer?.url;
    
    String? imageUrl;
    if (serverUrl != null && record.imageUrl != null) {
      imageUrl = '$serverUrl/Items/${record.itemId}/Images/Primary?tag=${record.imageUrl}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      color: AppTheme.surfaceColor,
      child: InkWell(
        onTap: () {
          context.push('/detail/${record.itemId}');
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 海报
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 120,
                        height: 160,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 120,
                          height: 160,
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          child: const Icon(Icons.movie, size: 40),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 120,
                          height: 160,
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          child: const Icon(Icons.error, size: 40),
                        ),
                      )
                    : Container(
                        width: 120,
                        height: 160,
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        child: const Icon(Icons.movie, size: 40),
                      ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            record.type == 'Movie' ? '电影' : '剧集',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          record.watchedAgo,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    // 进度条
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              record.displayPosition,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              record.displayDuration,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: record.progress.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[800],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // 操作按钮
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('继续播放'),
                          onPressed: () {
                            context.push('/detail/${record.itemId}');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () => _removeItem(record.itemId),
                          tooltip: '移除记录',
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
            Icons.history,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            '暂无观看历史',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            '开始观看视频，历史记录将显示在这里',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await _historyService.remove(itemId);
      setState(() {
        _records.removeWhere((r) => r.itemId == itemId);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败：$e')),
        );
      }
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有观看历史吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _historyService.clear();
        setState(() => _records = []);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('清空失败：$e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _historyService.close();
    super.dispose();
  }
}
