import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media_item.dart';

class LocalMediaService {
  static final LocalMediaService _instance = LocalMediaService._internal();
  factory LocalMediaService() => _instance;
  LocalMediaService._internal();

  final List<String> _mediaDirectories = [];
  final List<MediaItem> _cachedMedia = [];

  List<String> get mediaDirectories => List.unmodifiable(_mediaDirectories);

  /// 注册媒体目录
  Future<void> addMediaDirectory(String path) async {
    if (!_mediaDirectories.contains(path)) {
      _mediaDirectories.add(path);
      await scanDirectory(path);
    }
  }

  /// 移除媒体目录
  void removeMediaDirectory(String path) {
    _mediaDirectories.remove(path);
    _cachedMedia.removeWhere((item) => item.path?.startsWith(path) ?? false);
  }

  /// 扫描目录中的媒体文件
  Future<void> scanDirectory(String directory) async {
    try {
      final dir = Directory(directory);
      if (!await dir.exists()) return;

      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && _isMediaFile(entity.path)) {
          final mediaItem = _createMediaItemFromFile(entity);
          if (!_cachedMedia.any((m) => m.path == mediaItem.path)) {
            _cachedMedia.add(mediaItem);
          }
        }
      }
      debugPrint('扫描完成：${_cachedMedia.length} 个媒体文件');
    } catch (e) {
      debugPrint('扫描目录失败：$e');
    }
  }

  /// 获取所有本地媒体
  List<MediaItem> getAllMedia() {
    return List.unmodifiable(_cachedMedia);
  }

  /// 获取电影
  List<MediaItem> getMovies() {
    return _cachedMedia.where((item) => 
      item.type == 'Movie' || 
      item.name.toLowerCase().endsWith('.mp4') ||
      item.name.toLowerCase().endsWith('.mkv')
    ).toList();
  }

  /// 获取剧集
  List<MediaItem> getSeries() {
    // 简单判断：文件名包含 S01E01 或类似模式
    final episodeRegex = RegExp(r'[Ss]\d+[Ee]\d+|\d+x\d+');
    return _cachedMedia.where((item) => 
      item.type == 'Episode' ||
      episodeRegex.hasMatch(item.name)
    ).toList();
  }

  /// 继续观看
  List<MediaItem> getResumeItems() {
    // TODO: 需要实现本地播放进度追踪
    return [];
  }

  /// 最近添加
  List<MediaItem> getRecentlyAdded({int limit = 50}) {
    final sorted = List<MediaItem>.from(_cachedMedia)
      ..sort((a, b) => (b.statChanged ?? DateTime.now()).compareTo(a.statChanged ?? DateTime.now()));
    return sorted.take(limit).toList();
  }

  bool _isMediaFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return const {
      'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v',
      'mp3', 'flac', 'wav', 'aac', 'ogg', 'wma',
    }.contains(ext);
  }

  MediaItem _createMediaItemFromFile(File file) {
    final stat = file.statSync();
    final path = file.path;
    final name = file.path.split(Platform.pathSeparator).last;
    final size = stat.size;

    return MediaItem(
      id: 'local_${path.hashCode}',
      name: name.replaceAll(RegExp(r'\.[^.]+$'), ''),
      type: 'Movie',
      path: path,
      size: size,
      dateCreated: stat.changed,
      statChanged: stat.changed,
      runTimeTicks: null,
    );
  }

  /// 获取本地视频文件路径
  Future<String?> getLocalVideoPath(String itemId) async {
    final item = _cachedMedia.firstWhere(
      (m) => m.id == itemId,
      orElse: () => MediaItem(id: '', name: '', type: ''),
    );
    return item.path;
  }

  Future<void> rescan() async {
    _cachedMedia.clear();
    for (final dir in _mediaDirectories) {
      await scanDirectory(dir);
    }
  }

  void clearCache() {
    _cachedMedia.clear();
  }
}
