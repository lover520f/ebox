import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/server_provider.dart';
import '../../models/emby_server.dart';

class ServerListPage extends StatefulWidget {
  const ServerListPage({Key? key}) : super(key: key);

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('服务器'),
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF6C5CE7)),
            onPressed: () => context.push('/servers/add'),
            tooltip: '添加服务器',
          ),
        ],
      ),
      body: Consumer<ServerProvider>(
        builder: (context, serverProvider, child) {
          final servers = serverProvider.servers;
          
          if (servers.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: servers.length,
            itemBuilder: (context, index) {
              final server = servers[index];
              final isActive = serverProvider.activeServer?.id == server.id;
              return _buildServerCard(server, isActive);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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
            '暂无服务器',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '添加 Emby 服务器开始使用',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/servers/add'),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              '添加服务器',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard(EmbyServer server, bool isActive) {
    return Card(
      color: const Color(0xFF141414),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? const Color(0xFF6C5CE7) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.read<ServerProvider>().setActiveServer(server);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已切换到 ${server.name}'),
              backgroundColor: const Color(0xFF6C5CE7),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onLongPress: () => _showServerOptions(server),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 状态指示器
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: server.isOnline
                        ? [Colors.green.withOpacity(0.6), Colors.green.withOpacity(0.3)]
                        : [Colors.red.withOpacity(0.6), Colors.red.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  server.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // 服务器信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          server.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '活动中',
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      server.url,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              // 连接状态
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: server.isOnline ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    server.isOnline ? '在线' : '离线',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // 菜单按钮
              PopupMenuButton<String>(
                color: const Color(0xFF1E1E1E),
                onSelected: (value) {
                  if (value == 'edit') {
                    // TODO: 编辑服务器
                  } else if (value == 'delete') {
                    _confirmDelete(server);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('编辑', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('删除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServerOptions(EmbyServer server) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('编辑服务器', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: 编辑服务器
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.white),
              title: const Text('重新连接', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await context.read<ServerProvider>().testConnection(server);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除服务器', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(server);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(EmbyServer server) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('确认删除', style: TextStyle(color: Colors.white)),
        content: Text(
          '确定要删除服务器 "${server.name}" 吗？',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<ServerProvider>().removeServer(server);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('服务器已删除'),
            backgroundColor: const Color(0xFF6C5CE7),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
