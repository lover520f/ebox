import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeContent(),
          Placeholder(),
          Placeholder(),
          MyPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            context.push('/search');
          } else if (index == 2) {
            context.push('/servers');
          } else if (index == 3) {
            context.push('/history');
          }
        },
        backgroundColor: AppTheme.surfaceColor,
        indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: '搜索',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: '媒体库',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('E 宝盒'),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('继续观看', Icons.play_circle_outline, () {}),
            const SizedBox(height: AppTheme.spacingL),
            _buildSection('最近添加', Icons.add, () {}),
            const SizedBox(height: AppTheme.spacingL),
            _buildSection('我的媒体库', Icons.video_library, () {
              context.push('/servers');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, VoidCallback onNavigate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(icon),
              onPressed: onNavigate,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Center(
            child: Text(
              '功能开发中...',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: '观看历史',
            subtitle: '查看观看记录',
            onTap: () => context.push('/history'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.video_library,
            title: '媒体库',
            subtitle: '管理 Emby 服务器',
            onTap: () => context.push('/servers'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.local_movies,
            title: '本地媒体',
            subtitle: '浏览本地视频文件',
            onTap: () => context.push('/local'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: '设置',
            subtitle: '应用配置',
            onTap: () => context.push('/settings'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: '关于',
            subtitle: '版本 v2.1.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
