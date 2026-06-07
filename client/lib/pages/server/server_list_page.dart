import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/server_provider.dart';

class ServerListPage extends StatelessWidget {
  const ServerListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('服务器管理'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ServerProvider>(
        builder: (context, serverProvider, child) {
          final servers = serverProvider.servers;
          
          if (servers.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: servers.length,
            itemBuilder: (context, index) {
              final server = servers[index];
              final isActive = server.id == serverProvider.activeServer?.id;
              
              return _buildServerCard(context, server, isActive, serverProvider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/servers/add'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('添加服务器'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            child: const Icon(Icons.cloud_off, size: 50, color: Colors.white),
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
          const SizedBox(height: 16),
          Text(
            '点击右下角按钮添加 Emby 服务器',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard(BuildContext context, ServerInfo server, bool isActive, ServerProvider provider) {
    return Dismissible(
      key: Key(server.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        provider.removeServer(server.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已删除服务器'),
            backgroundColor: Color(0xFF6C5CE7),
          ),
        );
      },
      child: Card(
        color: isActive ? const Color(0xFF141414) : const Color(0xFF0D0D0D),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive ? const Color(0xFF6C5CE7) : Colors.white.withOpacity(0.1),
            width: isActive ? 2 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActive
                    ? [const Color(0xFF6C5CE7), const Color(0xFF00CEC9)]
                    : [Colors.grey[700]!, Colors.grey[800]!],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isActive ? Icons.cloud_done : Icons.cloud,
              color: Colors.white,
            ),
          ),
          title: Text(
            server.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            server.url,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          trailing: isActive
              ? const Icon(Icons.check_circle, color: Color(0xFF6C5CE7))
              : null,
          onTap: () {
            HapticFeedback.lightImpact();
            provider.setActiveServer(server.id);
          },
        ),
      ),
    );
  }
}
