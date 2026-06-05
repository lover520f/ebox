import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'emby_api_client.dart';

/// 专业级视频播放服务
/// 支持进度跟踪、播放报告、续播等功能
class VideoPlayerService extends ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;
  double _speed = 1.0;
  
  // 播放报告相关
  String? _itemId;
  EmbyApiClient? _apiClient;
  Timer? _progressTimer;
  DateTime? _playbackStartTime;

  // Getters
  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  bool get isVideoInitialized => _controller?.value.isInitialized ?? false;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get bufferedPosition => _bufferedPosition;
  double get volume => _volume;
  bool get isMuted => _isMuted;
  double get speed => _speed;
  EmbyApiClient? get apiClient => _apiClient;

  /// 设置 API 客户端用于播放报告
  void setApiClient(EmbyApiClient client) {
    _apiClient = client;
  }

  /// 初始化视频
  Future<void> initialize(String videoUrl, {String? itemId}) async {
    try {
      await dispose();
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      
      await _controller!.initialize();
      
      _controller!.addListener(_onPlayerChanged);
      
      _isInitialized = true;
      _itemId = itemId;
      _duration = _controller!.value.duration;
      
      notifyListeners();
    } catch (e) {
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  void _onPlayerChanged() {
    if (_controller == null) return;
    
    final value = _controller!.value;
    _position = value.position;
    _isPlaying = value.isPlaying;
    _bufferedPosition = value.buffered;
    
    // 定期报告播放进度（每 10 秒）
    if (_isPlaying && _position.inSeconds % 10 == 0) {
      _reportProgress();
    }
    
    // 视频播放完成
    if (_position >= _duration && _duration > Duration.zero) {
      _playbackComplete();
    }
    
    notifyListeners();
  }

  /// 开始播放并报告
  Future<void> play() async {
    if (_controller != null && _isInitialized) {
      await _controller!.play();
      _playbackStartTime = DateTime.now();
      if (_itemId != null && _apiClient != null) {
        await _apiClient!.reportPlaybackStart(_itemId!);
      }
      _startProgressTimer();
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    if (_controller != null && _isInitialized) {
      await _controller!.pause();
      _stopProgressTimer();
      _reportProgress();
    }
  }

  /// 切换播放/暂停
  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// 拖动进度
  Future<void> seekTo(Duration position) async {
    if (_controller != null && _isInitialized) {
      await _controller!.seekTo(position);
      _position = position;
      notifyListeners();
    }
  }

  /// 快进
  Future<void> forward(Duration duration) async {
    final newPosition = _position + duration;
    if (newPosition > _duration) {
      seekTo(_duration);
    } else {
      seekTo(newPosition);
    }
  }

  /// 快退
  Future<void> rewind(Duration duration) async {
    final newPosition = _position - duration;
    if (newPosition < Duration.zero) {
      seekTo(Duration.zero);
    } else {
      seekTo(newPosition);
    }
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    if (_controller != null && _isInitialized) {
      _volume = volume.clamp(0.0, 1.0);
      await _controller!.setVolume(_volume);
      _isMuted = _volume == 0;
      notifyListeners();
    }
  }

  /// 静音切换
  Future<void> toggleMute() async {
    if (_isMuted) {
      setVolume(_volume == 0 ? 1.0 : _volume);
      _isMuted = false;
    } else {
      setVolume(0.0);
      _isMuted = true;
    }
  }

  /// 设置播放速度
  Future<void> setSpeed(double speed) async {
    if (_controller != null && _isInitialized) {
      _speed = speed.clamp(0.25, 3.0);
      await _controller!.setPlaybackSpeed(_speed);
      notifyListeners();
    }
  }

  /// 开始进度定时器
  void _startProgressTimer() {
    _stopProgressTimer();
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _reportProgress();
    });
  }

  /// 停止进度定时器
  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// 报告播放进度
  Future<void> _reportProgress() async {
    if (_itemId != null && _apiClient != null) {
      try {
        await _apiClient!.reportPlaybackProgress(_itemId!, _position);
      } catch (e) {
        debugPrint('报告播放进度失败：$e');
      }
    }
  }

  /// 播放完成
  void _playbackComplete() {
    _stopProgressTimer();
    if (_itemId != null && _apiClient != null) {
      try {
        _apiClient!.reportPlaybackStopped(_itemId!, _position);
        // 标记为已播放
        _apiClient!.markPlayed(_itemId!);
      } catch (e) {
        debugPrint('报告播放完成失败：$e');
      }
    }
  }

  /// 停止播放（手动）
  void stop() {
    _stopProgressTimer();
    _reportProgress();
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopProgressTimer();
    _controller?.removeListener(_onPlayerChanged);
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    super.dispose();
  }
}
