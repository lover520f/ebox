import 'package:video_player/video_player.dart';
import 'media_streams_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'emby_api_client.dart';

class VideoPlayerService extends ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<DurationRange> _buffered = [];
  double _volume = 1.0;
  bool _isMuted = false;
  double _speed = 1.0;
  
  String? _itemId;
  EmbyApiClient? _apiClient;
  Timer? _progressTimer;

  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  bool get isVideoInitialized => _controller?.value.isInitialized ?? false;
  Duration get position => _position;
  Duration get duration => _duration;
  List<DurationRange> get buffered => _buffered;
  double get volume => _volume;
  bool get isMuted => _isMuted;
  double get speed => _speed;
  String? get itemId => _itemId;
  EmbyApiClient? get apiClient => _apiClient;

  void setApiClient(EmbyApiClient client) {
    _apiClient = client;
  }

  Future<void> initialize(String videoUrl, {String? itemId}) async {
    try {
      _controller?.removeListener(_onPlayerChanged);
      _controller?.dispose();
      
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
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
    _buffered = value.buffered;
    
    if (_isPlaying && _position.inSeconds % 10 == 0) {
      _reportProgress();
    }
    
    if (_position >= _duration && _duration > Duration.zero) {
      _playbackComplete();
    }
    
    notifyListeners();
  }

  Future<void> play() async {
    if (_controller != null && _isInitialized) {
      await _controller!.play();
      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _reportProgress();
      });
      if (_itemId != null && _apiClient != null) {
        await _apiClient!.reportPlaybackStart(_itemId!);
      }
    }
  }

  Future<void> pause() async {
    if (_controller != null && _isInitialized) {
      await _controller!.pause();
      _progressTimer?.cancel();
      _reportProgress();
    }
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_controller != null && _isInitialized) {
      await _controller!.seekTo(position);
      notifyListeners();
    }
  }

  Future<void> forward(Duration duration) async {
    final newPosition = _position + duration;
    seekTo(newPosition > _duration ? _duration : newPosition);
  }

  Future<void> rewind(Duration duration) async {
    final newPosition = _position - duration;
    seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  Future<void> setVolume(double volume) async {
    if (_controller != null && _isInitialized) {
      _volume = volume.clamp(0.0, 1.0);
      await _controller!.setVolume(_volume);
      _isMuted = _volume == 0;
      notifyListeners();
    }
  }

  Future<void> toggleMute() async {
    if (_isMuted) {
      setVolume(_volume == 0 ? 1.0 : _volume);
      _isMuted = false;
    } else {
      setVolume(0.0);
      _isMuted = true;
    }
  }

  Future<void> setSpeed(double speed) async {
    if (_controller != null && _isInitialized) {
      _speed = speed.clamp(0.25, 3.0);
      await _controller!.setPlaybackSpeed(_speed);
      notifyListeners();
    }
  }

  Future<void> _reportProgress() async {
    if (_itemId != null && _apiClient != null) {
      try {
        await _apiClient!.reportPlaybackProgress(_itemId!, _position);
      } catch (e) {
        debugPrint('报告播放进度失败：$e');
      }
    }
  }

  void _playbackComplete() {
    _progressTimer?.cancel();
    if (_itemId != null && _apiClient != null) {
      try {
        _apiClient!.reportPlaybackStopped(_itemId!, _position);
        _apiClient!.markPlayed(_itemId!);
      } catch (e) {
        debugPrint('报告播放完成失败：$e');
      }
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller?.removeListener(_onPlayerChanged);
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    super.dispose();
  }
}

  }
