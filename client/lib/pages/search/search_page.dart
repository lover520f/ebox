import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/media_provider.dart';
import '../../providers/server_provider.dart';
import '../../models/media_item.dart';
import '../../widgets/media_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<MediaItem> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String _lastQuery = '';
  
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _lastQuery = '';
      });
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      setState(() => _isSearching = true);
      
      try {
        final mediaProvider = context.read<MediaProvider>();
        final apiClient = mediaProvider.apiClient;
        
        if (apiClient != null) {
          final results = await apiClient.search(query);
          if (mounted) {
            setState(() {
              _results = results;
              _hasSearched = true;
              _lastQuery = query;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('搜索失败：$e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: '搜索电影、剧集、音乐...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _search('');
                    },
                  )
                : null,
          ),
          onChanged: _search,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            _debounceTimer?.cancel();
            _search(value);
          },
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        automaticallyImplyLeading: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppTheme.spacingL),
            Text(
              '正在搜索...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return _buildInitialState();
    }

    if (_results.isEmpty) {
      return _buildEmptyState();
    }

    return _buildResults();
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            '搜索媒体内容',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            '输入关键词搜索电影、剧集、音乐等',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          // 热门搜索标签
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingS,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickSearch('动作'),
              _buildQuickSearch('喜剧'),
              _buildQuickSearch('科幻'),
              _buildQuickSearch('剧情'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearch(String keyword) {
    return ActionChip(
      label: Text(keyword),
      onPressed: () {
        _searchController.text = keyword;
        _search(keyword);
      },
      backgroundColor: AppTheme.surfaceColor,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            '未找到相关内容',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            '尝试其他关键词或浏览媒体库',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 结果计数
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Text(
            '找到 ${_results.length} 个结果 "${_lastQuery}"',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ),
        // 结果网格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppTheme.spacingM,
              mainAxisSpacing: AppTheme.spacingM,
              childAspectRatio: 0.65,
            ),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              return MediaCard(item: _results[index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
