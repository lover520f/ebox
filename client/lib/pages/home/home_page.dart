import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/server_provider.dart';
import '../../providers/media_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 延迟加载以确保 ServerProvider 已初始化
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 等待一下确保 ServerProvider 已经加载完成
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        await context.read<MediaProvider>().loadLibraries();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();

    return Scaffold(
      body: Column(
        children: [
          // 顶部导航栏
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppTheme.spacingM,
              left: AppTheme.spacingM,
              right: AppTheme.spacingM,
            ),
            child: Row(
              children: [
                const Text(
                  'E 宝盒',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // TODO: 搜索功能
                  },
                  tooltip: '搜索',
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    context.goNamed('settings');
                  },
                  tooltip: '设置',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          // 内容区域
          Expanded(
            child: !serverProvider.isAuthenticated
                ? _buildNotAuthenticated()
                : _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Emby',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: '本地',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: AppTheme.surfaceColor,
        onTap: (index) {
          if (index == 1) {
            context.goNamed('servers');
          } else if (index == 2) {
            context.goNamed('local');
          }
        },
      ),
    );
  }

  Widget _buildNotAuthenticated() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppTheme.spacingL),
          const Text(
            '未连接到服务器',
            style: TextStyle(
              fontSize: 20,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          ElevatedButton(
            onPressed: () {
              context.goNamed('servers');
            },
            child: const Text('连接服务器'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final mediaProvider = context.watch<MediaProvider>();
    final libraries = mediaProvider.libraries;

    if (libraries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await mediaProvider.loadLibraries();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: libraries.length,
        itemBuilder: (context, index) {
          final library = libraries[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: InkWell(
              onTap: () {
                context.goNamed('library', pathParameters: {
                  'libraryId': library.id,
                });
              },
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppTheme.gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Icon(
                        _getLibraryIcon(library.collectionType),
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            library.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXS),
                          Text(
                            library.displayType,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getLibraryIcon(String? collectionType) {
    switch (collectionType) {
      case 'movies':
        return Icons.movie;
      case 'tvshows':
        return Icons.tv;
      case 'music':
        return Icons.music_note;
      case 'books':
        return Icons.book;
      default:
        return Icons.folder;
    }
  }
}
