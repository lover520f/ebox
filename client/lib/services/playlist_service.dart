import 'package:flutter/foundation.dart';
import '../models/media_item.dart';

/// 播放列表服务
/// 管理连续播放队列
class PlaylistService extends ChangeNotifier {
  List<MediaItem> _queue = [];
  int _currentIndex = -1;
  bool _isPlaying = false;

  List<MediaItem> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  MediaItem? get currentItem => _currentIndex >= 0 && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;
  bool get isPlaying => _isPlaying;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  /// 设置播放列表
  void setPlaylist(List<MediaItem> items, {int startIndex = 0}) {
    _queue = List.from(items);
    _currentIndex = startIndex.clamp(0, items.length - 1);
    _isPlaying = true;
    notifyListeners();
  }

  /// 添加到队列末尾
  void add(MediaItem item) {
    _queue.add(item);
    notifyListeners();
  }

  /// 播放下一集
  MediaItem? next() {
    if (hasNext) {
      _currentIndex++;
      notifyListeners();
      return _queue[_currentIndex];
    }
    return null;
  }

  /// 播放上一集
  MediaItem? previous() {
    if (hasPrevious) {
      _currentIndex--;
      notifyListeners();
      return _queue[_currentIndex];
    }
    return null;
  }

  /// 跳转到指定集
  void jumpTo(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      _isPlaying = true;
      notifyListeners();
    }
  }

  /// 开始/暂停
  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  /// 停止播放
  void stop() {
    _isPlaying = false;
    notifyListeners();
  }

  /// 清空队列
  void clear() {
    _queue.clear();
    _currentIndex = -1;
    _isPlaying = false;
    notifyListeners();
  }

  /// 移除指定项
  void removeAt(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      if (_currentIndex > index) {
        _currentIndex--;
      } else if (_currentIndex == index) {
        if (_currentIndex >= _queue.length) {
          _currentIndex = _queue.isEmpty ? -1 : _queue.length - 1;
        }
      }
      notifyListeners();
    }
  }
}
