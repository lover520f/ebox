import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/local_media_service.dart';
import '../../models/media_item.dart';
import '../../providers/player_provider.dart';
import '../../widgets/media_card.dart';

class LocalMediaPage extends StatefulWidget {
  const LocalMediaPage({Key? key}) : super(key: key);

  @override
  State<LocalMediaPage> createState() => _LocalMediaPageState();
}

class _LocalMediaPageState extends State<LocalMediaPage> {
  final LocalMediaService _localMediaService = LocalMediaService();
  int _selectedTab = 0;
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Row(
        children: [
          _buildSideNavigation(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text('本地媒体', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          _buildNavItem('全部', 0, Icons.folder_rounded),
          _buildNavItem('电影', 1, Icons.movie_rounded),
          _buildNavItem('剧集', 2, Icons.tv_rounded),
          const Spacer(),
          _buildNavItem('扫描', -1, Icons.refresh_rounded, isAction: true),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, int index, IconData icon, {bool isAction = false}) {
    final isSelected = _selectedTab == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[400], size: 24),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[400], fontSize: 15)),
      selected: isSelected,
      selectedTileColor: const Color(0xFF6C5CE7).withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {
        if (isAction) {
          _startScan();
        } else {
          setState(() => _selectedTab = index);
        }
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          const Text('本地媒体库', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _addDirectory,
            icon: const Icon(Icons.add_folder),
            label: const Text('添加目录'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7))),
            SizedBox(height: 16),
            Text('正在扫描媒体库...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    final mediaList = _getMediaList();
    if (mediaList.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: mediaList.length,
      itemBuilder: (context, index) => LocalMediaCard(item: mediaList[index]),
    );
  }

  List<MediaItem> _getMediaList() {
    switch (_selectedTab) {
      case 0: return _localMediaService.getAllMedia();
      case 1: return _localMediaService.getMovies();
      case 2: return _localMediaService.getSeries();
      default: return [];
    }
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
              gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)]),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(Icons.folder_open, size: 60, color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 32),
          const Text('暂无本地媒体', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text('点击"添加目录"来选择媒体文件夹', style: TextStyle(fontSize: 16, color: Colors.grey[400])),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addDirectory,
            icon: const Icon(Icons.add_folder),
            label: const Text('添加目录', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addDirectory() async {
    try {
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory != null) {
        await _localMediaService.addMediaDirectory(directory);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已添加：$directory'), backgroundColor: const Color(0xFF6C5CE7)),
          );
        }
      }
    } catch (e) {
      debugPrint('添加目录失败：$e');
    }
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    await _localMediaService.rescan();
    setState(() => _isScanning = false);
  }
}

class LocalMediaCard extends StatelessWidget {
  final MediaItem item;

  const LocalMediaCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final playerProvider = context.read<PlayerProvider>();
        playerProvider.playLocalMedia(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('开始播放：${item.name}'), backgroundColor: const Color(0xFF6C5CE7)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)]),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(
                  child: Icon(Icons.video_file, size: 60, color: Colors.white70),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(_formatSize(item.size ?? 0), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
