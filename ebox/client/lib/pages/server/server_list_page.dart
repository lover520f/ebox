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
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppTheme.spacingM),
            leading: Container(
              width: 48,
              height: 48,
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
              ),
            ),
            title: Text(
              server.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'connect':
                    serverProvider.connectToServer(server.id);
                    break;
                  case 'edit':
                    // TODO: 编辑服务器
                    break;
                  case 'delete':
                    _showDeleteDialog(context, server);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'connect',
                  child: ListTile(
                    leading: Icon(Icons.link),
                    title: Text('连接'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('编辑'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: AppTheme.errorColor),
                    title: Text('删除', style: TextStyle(color: AppTheme.errorColor)),
                  ),
                ),
              ],
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
