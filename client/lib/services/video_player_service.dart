import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

class VideoPlayerService extends ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;
  double _speed = 1.0;

  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get isMuted => _isMuted;
  double get speed => _speed;

  // 初始化视频
  Future<void> initialize(String videoUrl) async {
    try {
      _controller?.dispose();
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      
      await _controller!.initialize();
      
      _controller!.addListener(() {
        _position = _controller!.value.position;
        _isPlaying = _controller!.value.isPlaying;
        notifyListeners();
      });
      
      _duration = _controller!.value.duration;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  // 初始化本地文件
  Future<void> initializeFile(String filePath) async {
    try {
      _controller?.dispose();
      
      _controller = VideoPlayerController.file(
        filePath.toString() as dynamic,
      );
      
      await _controller!.initialize();
      
      _controller!.addListener(() {
        _position = _controller!.value.position;
        _isPlaying = _controller!.value.isPlaying;
        notifyListeners();
      });
      
      _duration = _controller!.value.duration;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  // 播放
  Future<void> play() async {
    if (_controller != null && _isInitialized) {
      await _controller!.play();
      _isPlaying = true;
      notifyListeners();
    }
  }

  // 暂停
  Future<void> pause() async {
    if (_controller != null && _isInitialized) {
      await _controller!.pause();
      _isPlaying = false;
      notifyListeners();
    }
  }

  // 切换播放/暂停
  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  // 拖动进度
  Future<void> seekTo(Duration moment) async {
    if (_controller != null && _isInitialized) {
      await _controller!.seekTo(moment);
      _position = moment;
      notifyListeners();
    }
  }

  // 快进
  Future<void> forward(Duration duration) async {
    final newPosition = _position + duration;
    if (newPosition > _duration) {
      seekTo(_duration);
    } else {
      seekTo(newPosition);
    }
  }

  // 快退
  Future<void> rewind(Duration duration) async {
    final newPosition = _position - duration;
    if (newPosition < Duration.zero) {
      seekTo(Duration.zero);
    } else {
      seekTo(newPosition);
    }
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    if (_controller != null && _isInitialized) {
      _volume = volume.clamp(0.0, 1.0);
      await _controller!.setVolume(_volume);
      _isMuted = _volume == 0;
      notifyListeners();
    }
  }

  // 静音切换
  Future<void> toggleMute() async {
    if (_isMuted) {
      setVolume(_volume == 0 ? 1.0 : _volume);
      _isMuted = false;
    } else {
      setVolume(0.0);
      _isMuted = true;
    }
    notifyListeners();
  }

  // 设置播放速度
  Future<void> setSpeed(double speed) async {
    if (_controller != null && _isInitialized) {
      _speed = speed;
      await _controller!.setPlaybackSpeed(speed);
      notifyListeners();
    }
  }

  // 获取缩略图
  Future<void> requestThumbnail(Duration at) async {
    // TODO: 实现缩略图生成
  }

  // 清理资源
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
