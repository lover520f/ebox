import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/media_item.dart';

/// 观看历史服务
/// 管理本地观看历史记录
class WatchHistoryService {
  static const String _boxName = 'watch_history';
  late Box<Map> _box;

  /// 初始化
  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  /// 添加观看记录
  Future<void> addItem(MediaItem item, {
    required Duration position,
    required Duration duration,
    required DateTime watchedAt,
    double? progress,
  }) async {
    final record = WatchHistoryRecord(
      itemId: item.id,
      name: item.name,
      type: item.type ?? 'Movie',
      imageUrl: item.imageTags?.isNotEmpty == true 
          ? item.imageTags!.keys.first 
          : null,
      position: position.inMilliseconds,
      duration: duration.inMilliseconds,
      progress: progress ?? (position.inMilliseconds / duration.inMilliseconds),
      watchedAt: watchedAt,
    );
    
    await _box.put(item.id, record.toMap());
  }

  /// 获取所有观看历史
  List<WatchHistoryRecord> getAll({
    int limit = 100,
    DateTime? after,
  }) {
    final records = _box.values
        .map((e) => WatchHistoryRecord.fromMap(e as Map))
        .toList();
    
    // 按观看时间倒序
    records.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    
    // 过滤时间
    if (after != null) {
      records.removeWhere((r) => r.watchedAt.isBefore(after));
    }
    
    // 限制数量
    if (records.length > limit) {
      return records.sublist(0, limit);
    }
    
    return records;
  }

  /// 获取单个记录
  WatchHistoryRecord? get(String itemId) {
    final data = _box.get(itemId);
    if (data == null) return null;
    return WatchHistoryRecord.fromMap(data);
  }

  /// 删除记录
  Future<void> remove(String itemId) async {
    await _box.delete(itemId);
  }

  /// 清空所有历史
  Future<void> clear() async {
    await _box.clear();
  }

  /// 获取记录数量
  int get length => _box.length;

  /// 关闭
  Future<void> close() async {
    await _box.close();
  }
}

/// 观看历史记录
class WatchHistoryRecord {
  final String itemId;
  final String name;
  final String type;
  final String? imageUrl;
  final int positionMs;
  final int durationMs;
  final double progress;
  final DateTime watchedAt;

  const WatchHistoryRecord({
    required this.itemId,
    required this.name,
    required this.type,
    this.imageUrl,
    required this.positionMs,
    required this.durationMs,
    required this.progress,
    required this.watchedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'type': type,
      'imageUrl': imageUrl,
      'positionMs': positionMs,
      'durationMs': durationMs,
      'progress': progress,
      'watchedAt': watchedAt.toIso8601String(),
    };
  }

  factory WatchHistoryRecord.fromMap(Map map) {
    return WatchHistoryRecord(
      itemId: map['itemId'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      imageUrl: map['imageUrl'] as String?,
      positionMs: map['positionMs'] as int,
      durationMs: map['durationMs'] as int,
      progress: (map['progress'] as num).toDouble(),
      watchedAt: DateTime.parse(map['watchedAt'] as String),
    );
  }

  Duration get position => Duration(milliseconds: positionMs);
  Duration get duration => Duration(milliseconds: durationMs);
  
  String get displayPosition {
    final hours = position.inHours;
    final minutes = position.inMinutes.remainder(60);
    final seconds = position.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  String get displayDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  String get watchedAgo {
    final now = DateTime.now();
    final diff = now.difference(watchedAt);
    
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} 年前';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} 个月前';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} 天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} 小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} 分钟前';
    } else {
      return '刚刚';
    }
  }
}
