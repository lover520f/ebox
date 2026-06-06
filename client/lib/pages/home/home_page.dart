import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/media_provider.dart';
import '../../providers/server_provider.dart';
import '../../models/media_item.dart';
import '../../widgets/media_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  
  final List<String> _navItems = ['首页', '电影', '剧集', '本地'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Row(
        children: [
          _buildSideNavigation(),
          Expanded(
            child: IndexedStack(
              index: _selectedNavIndex,
              children: [
                _buildHomeContent(),
                _buildMoviesContent(),
                _buildSeriesContent(),
                _buildLocalContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C5CE7),
                        const Color(0xFF00CEC9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'E 宝盒',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedNavIndex == index;
                return _buildNavItem(_navItems[index], index, isSelected);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Consumer<ServerProvider>(
              builder: (context, serverProvider, child) {
                final server = serverProvider.activeServer;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server?.name ?? '未连接',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: server != null ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          server != null ? '已连接' : '未连接',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, int index, bool isSelected) {
    IconData icon;
    switch (index) {
      case 0: icon = Icons.home_rounded; break;
      case 1: icon = Icons.movie_rounded; break;
      case 2: icon = Icons.tv_rounded; break;
      case 3: icon = Icons.folder_rounded; break;
      default: icon = Icons.home_rounded;
    }

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[400],
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[400],
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF6C5CE7).withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        // 切换时刷新对应页面数据
        if (index == 1 || index == 2) {
          _loadLibraryContent();
        }
      },
    );
  }

  void _loadLibraryContent() {
    // TODO: 触发数据加载
  }

  Widget _buildHomeContent() {
    return Consumer<ServerProvider>(
      builder: (context, serverProvider, child) {
        final isConnected = serverProvider.activeServer != null;
        
        if (!isConnected) {
          return _buildNoServerState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 40),
              _buildSectionTitle('继续观看', Icons.play_circle_outline),
              const SizedBox(height: 16),
              _buildContinueWatchingRow(),
              const SizedBox(height: 40),
              _buildSectionTitle('最近添加', Icons.add_circle_outline),
              const SizedBox(height: 16),
              _buildRecentlyAddedGrid(),
              const SizedBox(height: 40),
              _buildSectionTitle('为你推荐', Icons.star_outline),
              const SizedBox(height: 16),
              _buildRecommendedGrid(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.8),
            const Color(0xFF00CEC9).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 40,
            bottom: 0,
            child: Icon(
              Icons.movie_filter,
              size: 200,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '欢迎回来',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '开始探索精彩内容',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedNavIndex = 1;
                    });
                  },
                  icon: const Icon(Icons.play_arrow, color: Color(0xFF6C5CE7)),
                  label: const Text(
                    '开始观看',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6C5CE7), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingRow() {
    return FutureBuilder<List<MediaItem>>(
      future: _loadResumeItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _buildEmptySection('暂无继续观看的内容');
        }
        
        return SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length > 10 ? 10 : items.length,
            itemBuilder: (context, index) {
              return MediaCard(item: items[index], width: 200);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentlyAddedGrid() {
    return FutureBuilder<List<MediaItem>>(
      future: _loadRecentlyAdded(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _buildEmptySection('暂无最近添加的内容');
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemCount: items.length > 12 ? 12 : items.length,
          itemBuilder: (context, index) {
            return MediaCard(item: items[index]);
          },
        );
      },
    );
  }

  Widget _buildRecommendedGrid() {
    return FutureBuilder<List<MediaItem>>(
      future: _loadRecommended(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _buildEmptySection('暂无推荐内容');
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemCount: items.length > 12 ? 12 : items.length,
          itemBuilder: (context, index) {
            return MediaCard(item: items[index]);
          },
        );
      },
    );
  }

  Future<List<MediaItem>> _loadResumeItems() async {
    try {
      final mediaProvider = context.read<MediaProvider>();
      final apiClient = mediaProvider.apiClient;
      if (apiClient == null) return [];
      return await apiClient.getResumeItems(limit: 20);
    } catch (e) {
      debugPrint('加载续播失败：$e');
      return [];
    }
  }

  Future<List<MediaItem>> _loadRecentlyAdded() async {
    try {
      final mediaProvider = context.read<MediaProvider>();
      final apiClient = mediaProvider.apiClient;
      if (apiClient == null) return [];
      return await apiClient.getRecentlyAdded(limit: 20);
    } catch (e) {
      debugPrint('加载最近添加失败：$e');
      return [];
    }
  }

  Future<List<MediaItem>> _loadRecommended() async {
    try {
      final mediaProvider = context.read<MediaProvider>();
      final apiClient = mediaProvider.apiClient;
      if (apiClient == null) return [];
      // 临时实现：返回最近添加
      return await apiClient.getRecentlyAdded(limit: 20);
    } catch (e) {
      debugPrint('加载推荐失败：$e');
      return [];
    }
  }

  Widget _buildNoServerState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7).withOpacity(0.6),
                  const Color(0xFF00CEC9).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(Icons.cloud_off, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text(
            '未连接服务器',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '请先添加 Emby 服务器',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/servers'),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              '添加服务器',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMoviesContent() {
    return _buildLibraryView('电影', 'Movie');
  }

  Widget _buildSeriesContent() {
    return _buildLibraryView('剧集', 'Series');
  }

  Widget _buildLibraryView(String title, String type) {
    return FutureBuilder<List<MediaItem>>(
      future: _loadLibraryData(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                ),
                const SizedBox(height: 24),
                Text(
                  '正在加载$title库...',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'Movie' ? Icons.movie : Icons.tv,
                  size: 120,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 32),
                Text(
                  '暂无${title}内容',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '请先在 Emby 服务器中添加媒体',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(32),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return MediaCard(item: items[index]);
          },
        );
      },
    );
  }

  Future<List<MediaItem>> _loadLibraryData(String type) async {
    try {
      final mediaProvider = context.read<MediaProvider>();
      final apiClient = mediaProvider.apiClient;
      if (apiClient == null) return [];
      
      // 获取第一个媒体库的内容
      final libraries = await apiClient.getUserViews();
      if (libraries.isEmpty) return [];
      
      final targetLibrary = libraries.firstWhere(
        (lib) => lib.collectionType?.toLowerCase() == type.toLowerCase(),
        orElse: () => libraries.first,
      );
      
      return await apiClient.getLibraryItems(parentId: targetLibrary.id);
    } catch (e) {
      debugPrint('加载媒体库失败：$e');
      return [];
    }
  }

  Widget _buildLocalContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 120,
            color: const Color(0xFF6C5CE7).withOpacity(0.6),
          ),
          const SizedBox(height: 32),
          const Text(
            '本地媒体',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '请添加本地媒体目录',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('本地媒体功能开发中'),
                  backgroundColor: Color(0xFF6C5CE7),
                ),
              );
            },
            icon: const Icon(Icons.folder, color: Colors.white),
            label: const Text(
              '添加目录',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
