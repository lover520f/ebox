import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:async';

import '../../config/theme.dart';
import '../../models/media_item.dart';
import '../../widgets/media_card.dart';

class LocalMediaPage extends StatefulWidget {
  const LocalMediaPage({super.key});

  @override
  State<LocalMediaPage> createState() => _LocalMediaPageState();
}

class _LocalMediaPageState extends State<LocalMediaPage> {
  String? _scanPath;
  List<MediaItem> _videos = [];
  bool _isScanning = false;
  int _gridColumns = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('本地媒体'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _selectFolder,
            tooltip: '选择文件夹',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _scanPath != null ? _scanLocalFiles : null,
            tooltip: '重新扫描',
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() => _gridColumns = value);
            },
            itemBuilder: (context) => [
              _buildColumnMenuItem(2),
              _buildColumnMenuItem(3),
              _buildColumnMenuItem(4),
              _buildColumnMenuItem(5),
              _buildColumnMenuItem(6),
            ],
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_scanPath == null) {
      return _buildEmptyState();
    }

    if (_isScanning) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_videos.isEmpty) {
      return _buildNoVideosState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridColumns,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return MediaCard(item: _videos[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppTheme.spacingL),
          const Text(
            '请选择要扫描的文件夹',
            style: TextStyle(
              fontSize: 20,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          ElevatedButton.icon(
            onPressed: _selectFolder,
            icon: const Icon(Icons.folder),
            label: const Text('选择文件夹'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVideosState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppTheme.spacingL),
          const Text(
            '未发现视频文件',
            style: TextStyle(
              fontSize: 20,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            '文件夹：$_scanPath',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFolder() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      
      if (selectedDirectory != null) {
        setState(() {
          _scanPath = selectedDirectory;
        });
        await _scanLocalFiles();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择文件夹失败：$e')),
        );
      }
    }
  }

  Future<void> _scanLocalFiles() async {
    if (_scanPath == null) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final directory = Directory(_scanPath!);
      final videoExtensions = ['.mp4', '.mkv', '.avi', '.wmv', '.flv', '.mov'];
      
      List<MediaItem> foundVideos = [];
      
      await for (var entity in directory.list(recursive: true)) {
        if (entity is File) {
          final extension = entity.path.substring(entity.path.lastIndexOf('.')).toLowerCase();
          if (videoExtensions.contains(extension)) {
            // 从文件名提取信息
            final fileName = entity.path.split(Platform.pathSeparator).last;
            final title = _parseTitleFromFileName(fileName);
            
            foundVideos.add(MediaItem(
              id: entity.path,
              name: title,
              type: 'Movie',
              productionYear: _parseYearFromFileName(fileName),
            ));
          }
        }
      }

      setState(() {
        _videos = foundVideos;
        _isScanning = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('扫描失败：$e')),
        );
      }
      setState(() {
        _isScanning = false;
      });
    }
  }

  String _parseTitleFromFileName(String fileName) {
    // 移除扩展名
    var title = fileName.substring(0, fileName.lastIndexOf('.'));
    
    // 移除年份
    title = title.replaceAll(RegExp(r'\(\d{4}\)'), '');
    title = title.replaceAll(RegExp(r'\[\d{4}\]'), '');
    
    // 移除常见标记
    title = title.replaceAll(RegExp(r'\.|\-|_'), ' ');
    title = title.replaceAll(RegExp(r'\d{3,4}p'), '');
    title = title.replaceAll('BluRay', '');
    title = title.replaceAll('DVDRip', '');
    
    // 清理多余空格
    title = title.trim();
    title = title.replaceAll(RegExp(r'\s+'), ' ');
    
    return title;
  }

  int? _parseYearFromFileName(String fileName) {
    // 尝试从文件名中提取年份
    final match = RegExp(r'[\(\[](\d{4})[\)\]]').firstMatch(fileName);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  PopupMenuItem<int> _buildColumnMenuItem(int columns) {
    return PopupMenuItem(
      value: columns,
      child: ListTile(
        leading: Icon(_gridColumns == columns ? Icons.check : Icons.view_module),
        title: Text('$columns 列'),
      ),
    );
  }
}
