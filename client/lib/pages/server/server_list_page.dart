import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/server_provider.dart';
import '../../models/emby_server.dart';

class ServerListPage extends StatelessWidget {
  const ServerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final servers = serverProvider.servers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.goNamed('server-add');
            },
            tooltip: '添加服务器',
          ),
        ],
      ),
      body: servers.isEmpty
          ? _buildEmptyState(context)
          : _buildServerList(context, servers),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppTheme.spacingL),
          const Text(
            '暂无服务器',
            style: TextStyle(
              fontSize: 20,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            '添加你的 Emby 服务器开始使用',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton(
            onPressed: () {
              context.goNamed('server-add');
            },
            child: const Text('添加服务器'),
          ),
        ],
      ),
    );
  }

  Widget _buildServerList(BuildContext context, List<EmbyServer> servers) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: servers.length,
      itemBuilder: (context, index) {
        final server = servers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: InkWell(
            onTap: () async {
              // 点击卡片直接连接服务器
              final provider = context.read<ServerProvider>();
              final success = await provider.connectToServer(server.id);
              if (success && context.mounted) {
                // 连接成功后跳转到首页
                context.goNamed('home');
              }
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: server.isActive
                          ? const LinearGradient(colors: AppTheme.gradientColors)
                          : null,
                      color: server.isActive ? null : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(
                      server.isActive ? Icons.cloud_done : Icons.cloud_off,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          server.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          server.url,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (server.username != null) ...[
                          const SizedBox(height: AppTheme.spacingXS),
                          Text(
                            '用户：${server.username}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (server.isActive)
                    const Icon(Icons.check_circle, color: AppTheme.successColor)
                  else
                    const Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, EmbyServer server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除服务器"${server.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ServerProvider>().removeServer(server.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
