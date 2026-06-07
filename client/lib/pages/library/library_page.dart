import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/emby_api_service.dart';
import '../../providers/server_provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _mediaItems = [];
  String _error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('媒体库'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_mediaItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.folder_open, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              '暂无媒体内容',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请在 Emby 服务器中添加媒体',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF6C5CE7),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: _mediaItems.length,
        itemBuilder: (context, index) {
          final item = _mediaItems[index];
          return _buildMediaCard(item);
        },
      ),
    );
  }

  Widget _buildMediaCard(Map<String, dynamic> item) {
    final name = item['Name'] as String? ?? '未知';
    final year = item['ProductionYear'];
    final hasImage = item['ImageTags']?['Primary'] != null;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('点击了：$name'),
            backgroundColor: const Color(0xFF6C5CE7),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: hasImage
                  ? Image.network(
                      _getImageUrl(item['Id'], item['ImageTags']['Primary']),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFF141414),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalDuration != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF6C5CE7),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (year != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      year.toString(),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
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
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF141414),
      child: const Center(
        child: Icon(
          Icons.movie,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _getImageUrl(String itemId, String tag) {
    final server = context.read<ServerProvider>().activeServer;
    if (server == null) return '';
    return '${server.url}/Items/$itemId/Images/Primary?tag=$tag&api_key=${server.apiKey}';
  }

  Future<void> _loadData() async {
    final serverProvider = context.read<ServerProvider>();
    final server = serverProvider.activeServer;

    if (server == null) {
      setState(() => _error = '请先添加服务器');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final api = EmbyApiService(
        baseUrl: server.url,
        apiKey: server.apiKey,
        userId: '1',
      );

      final views = await api.getUserViews();
      print('媒体库数量：${views.length}');

      if (views.isEmpty) {
        setState(() {
          _isLoading = false;
          _mediaItems = [];
        });
        return;
      }

      final items = await api.getLibraryItems(
        parentId: views.first['Id'],
        limit: 50,
      );

      setState(() {
        _mediaItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载失败：$e';
        _isLoading = false;
      });
    }
  }
}
