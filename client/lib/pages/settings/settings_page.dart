import 'package:flutter/material.dart';

import '../../config/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          _buildSection(
            context,
            title: '外观',
            children: [
              _buildListTile(
                icon: Icons.palette_outlined,
                title: '主题',
                subtitle: '深色主题',
                onTap: () {
                  // TODO: 主题切换
                },
              ),
              _buildListTile(
                icon: Icons.grid_view_outlined,
                title: '网格视图列数',
                subtitle: '4 列',
                onTap: () {
                  // TODO: 调整列数
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          _buildSection(
            context,
            title: '播放',
            children: [
              _buildListTile(
                icon: Icons.speed_outlined,
                title: '默认播放速度',
                subtitle: '1.0x',
                onTap: () {
                  // TODO: 播放速度设置
                },
              ),
              _buildListTile(
                icon: Icons.hd_outlined,
                title: '默认画质',
                subtitle: '原始',
                onTap: () {
                  // TODO: 画质设置
                },
              ),
              _buildListTile(
                icon: Icons.subtitles_outlined,
                title: '字幕偏好',
                subtitle: '自动加载',
                onTap: () {
                  // TODO: 字幕设置
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          _buildSection(
            context,
            title: '存储',
            children: [
              _buildListTile(
                icon: Icons.storage_outlined,
                title: '清除缓存',
                onTap: () {
                  _showClearCacheDialog(context);
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          _buildSection(
            context,
            title: '关于',
            children: [
              _buildListTile(
                icon: Icons.info_outline,
                title: '应用版本',
                subtitle: '1.0.0',
              ),
              _buildListTile(
                icon: Icons.code_outlined,
                title: '开源协议',
                subtitle: 'MIT',
                onTap: () {
                  // TODO: 显示开源协议
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spacingM, bottom: AppTheme.spacingS),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 清除缓存
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }
}
