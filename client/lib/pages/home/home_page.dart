import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/server_provider.dart';
import '../library/library_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('E 宝盒'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ServerProvider>(
        builder: (context, serverProvider, child) {
          final server = serverProvider.activeServer;
          if (server == null) {
            return _buildWelcome(context);
          }
          return _buildHome(context, server);
        },
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(Icons.play_arrow, size: 70, color: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text(
            'E 宝盒',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hills 风格 Emby 客户端',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => context.go('/servers'),
            icon: const Icon(Icons.add, size: 24),
            label: const Text('添加服务器', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHome(BuildContext context, ServerInfo server) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServerCard(server),
          const SizedBox(height: 24),
          _buildFeatureGrid(context, server),
        ],
      ),
    );
  }

  Widget _buildServerCard(ServerInfo server) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  server.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  server.url,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, ServerInfo server) {
    final features = [
      {'icon': Icons.movie, 'title': '电影', 'enabled': true},
      {'icon': Icons.tv, 'title': '剧集', 'enabled': true},
      {'icon': Icons.play_circle, 'title': '继续观看', 'enabled': true},
      {'icon': Icons.folder, 'title': '本地媒体', 'enabled': false},
      {'icon': Icons.search, 'title': '搜索', 'enabled': false},
      {'icon': Icons.settings, 'title': '设置', 'enabled': false},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(context, feature);
      },
    );
  }

  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
    final enabled = feature['enabled'] as bool;

    return GestureDetector(
      onTap: () {
        if (feature['title'] == '电影' || feature['title'] == '剧集' || feature['title'] == '继续观看') {
          context.push('/library');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${feature['title']} 功能开发中'),
              backgroundColor: const Color(0xFF6C5CE7),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              feature['icon'] as IconData,
              size: 40,
              color: enabled ? const Color(0xFF6C5CE7) : Colors.grey[600],
            ),
            const SizedBox(height: 12),
            Text(
              feature['title'] as String,
              style: TextStyle(
                fontSize: 16,
                color: enabled ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
