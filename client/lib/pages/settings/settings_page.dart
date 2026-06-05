import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../config/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _useHardwareDecode = true;
  double _defaultVolume = 1.0;
  String _cacheSize = '500MB';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('播放设置'),
          SwitchListTile(
            title: const Text('硬件解码'),
            subtitle: const Text('启用 GPU 加速解码（更流畅）'),
            value: _useHardwareDecode,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() => _useHardwareDecode = value);
            },
          ),
          ListTile(
            title: const Text('默认音量'),
            subtitle: Text('${(_defaultVolume * 100).toInt()}%'),
            trailing: Slider(
              value: _defaultVolume,
              min: 0,
              max: 1,
              divisions: 10,
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                setState(() => _defaultVolume = value);
              },
            ),
          ),
          ListTile(
            title: const Text('播放速度'),
            subtitle: const Text('默认 1.0x'),
            trailing: const Icon(Icons.play_arrow),
            onTap: () => _showSpeedDialog(),
          ),
          const Divider(height: 1),
          
          _buildSectionHeader('缓存管理'),
          ListTile(
            title: const Text('缓存大小'),
            subtitle: Text(_cacheSize),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCacheDialog(),
          ),
          ListTile(
            title: const Text('清除缓存'),
            subtitle: const Text('释放存储空间'),
            trailing: const Icon(Icons.delete_outline, color: Colors.red),
            onTap: () => _confirmClearCache(),
          ),
          const Divider(height: 1),
          
          _buildSectionHeader('界面设置'),
          SwitchListTile(
            title: const Text('深色模式'),
            subtitle: const Text('跟随系统'),
            value: true,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {},
          ),
          ListTile(
            title: const Text('网格列数'),
            subtitle: const Text('首页和媒体库显示'),
            trailing: const Text('4 列'),
            onTap: () => _showGridColumnsDialog(),
          ),
          const Divider(height: 1),
          
          _buildSectionHeader('服务器'),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Emby 服务器'),
            subtitle: const Text('管理已添加的服务器'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/servers'),
          ),
          const Divider(height: 1),
          
          _buildSectionHeader('关于'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于 E 宝盒'),
            subtitle: const Text('版本 v2.1.0'),
            onTap: () => _showAboutDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('开源许可'),
            onTap: () => _showLicenseDialog(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('默认播放速度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1.0, 1.25, 1.5, 2.0].map((speed) {
            return ListTile(
              title: Text('${speed}x'),
              onTap: () {
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('缓存大小'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['200MB', '500MB', '1GB', '2GB'].map((size) {
            return ListTile(
              title: Text(size),
              onTap: () {
                setState(() => _cacheSize = size);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _confirmClearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？这不会影响您的观看历史。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Hive.deleteFromDisk();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('缓存已清除')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('清除失败：$e')),
          );
        }
      }
    }
  }

  void _showGridColumnsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('网格列数'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('3 列'), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('4 列'), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('5 列'), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('6 列'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于 E 宝盒'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('版本：v2.1.0'),
            const SizedBox(height: 8),
            const Text('E 宝盒是一款跨平台 Emby 客户端'),
            const SizedBox(height: 8),
            const Text('支持 Windows、Android TV、iOS 等平台'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLicenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开源许可'),
        content: const Text('本项目使用以下开源库:\n- Flutter\n- video_player\n- go_router\n- provider\n- hive\n- cached_network_image\n等'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
