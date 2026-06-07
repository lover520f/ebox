import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/server_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Consumer<ServerProvider>(
          builder: (context, serverProvider, child) {
            final server = serverProvider.activeServer;
            if (server == null) {
              return _buildWelcome();
            }
            return _buildHome();
          },
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
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
          child: const Icon(Icons.play_arrow, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 32),
        const Text('E 宝盒', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        const Text('Hills 风格 Emby 客户端', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => context.push('/servers'),
          icon: const Icon(Icons.add),
          label: const Text('添加服务器'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildHome() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('首页', style: TextStyle(fontSize: 24, color: Colors.white)),
        const SizedBox(height: 16),
        Text('已连接服务器', style: TextStyle(color: Colors.grey[400])),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.push('/servers'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
          ),
          child: const Text('管理服务器'),
        ),
      ],
    );
  }
}
