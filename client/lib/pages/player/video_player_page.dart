import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../config/theme.dart';
import '../../services/video_player_service.dart';
import '../../providers/server_provider.dart';

class VideoPlayerPage extends StatefulWidget {
  final String itemId;
  final String serverId;
  final String? videoUrl;

  const VideoPlayerPage({
    super.key,
    required this.itemId,
    required this.serverId,
    this.videoUrl,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerService _playerService;
  bool _showControls = true;
  bool _isBuffering = true;
  String? _errorMessage;
  
  DateTime _lastInteractionTime = DateTime.now();
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _playerService = VideoPlayerService();
    _initializePlayer();
  }

  void _initializePlayer() async {
    try {
      setState(() => _isBuffering = true);
      
      final serverProvider = context.read<ServerProvider>();
      final apiClient = serverProvider.apiClient;
      
      String videoUrl = widget.videoUrl ?? '';
      
      // 如果没有传入 videoUrl，从 Emby 获取
      if (videoUrl.isEmpty) {
        videoUrl = await apiClient.getPlaybackUrl(widget.itemId);
      }
      
      // 初始化播放器
      await _playerService.initialize(videoUrl);
      
      setState(() {
        _isBuffering = false;
      });
      
      // 自动开始播放
      _playerService.play();
      
    } catch (e) {
      setState(() {
        _isBuffering = false;
        _errorMessage = '视频加载失败：$e';
      });
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _playerService.dispose();
    super.dispose();
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _lastInteractionTime = DateTime.now();
    
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (_playerService.isPlaying && mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 视频区域
          Positioned.fill(
            child: Center(
              child: _playerService.isInitialized
                  ? AspectRatio(
                      aspectRatio: _playerService.controller!.value.aspectRatio,
                      child: VideoPlayer(_playerService.controller!),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // 返回按钮（始终显示在顶层）
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: () {
                context.pop();
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
          // 错误提示
          if (_errorMessage != null)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildVideoArea() {
    return GestureDetector(
      onTap: _showControlsTemporarily,
      onDoubleTap: () {
        final screenState = _playerService.isPlaying ? _playerService.position.inSeconds : 0;
        if (screenState < 5) {
          _playerService.rewind(const Duration(seconds: 10));
        } else {
          _playerService.forward(const Duration(seconds: 10));
        }
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: _playerService.controller?.value.aspectRatio ?? 16 / 9,
          child: VideoPlayer(_playerService.controller!),
        ),
      ),
    );
  }

  Widget buildBufferingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              '正在加载...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _initializePlayer();
              },
              child: const Text('重试'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppTheme.spacingM,
        left: AppTheme.spacingM,
        right: AppTheme.spacingM,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.pop();
            },
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Text(
              '视频播放',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              _showSettingsMenu();
            },
          ),
        ],
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        bottom: AppTheme.spacingM,
        left: AppTheme.spacingM,
        right: AppTheme.spacingM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度条
          buildProgressBar(),
          const SizedBox(height: AppTheme.spacingM),
          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 快退 10 秒
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                onPressed: () {
                  _playerService.rewind(const Duration(seconds: 10));
                },
                iconSize: 32,
              ),
              // 播放/暂停
              IconButton(
                icon: Icon(
                  _playerService.isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: () {
                  _playerService.togglePlayPause();
                  _showControlsTemporarily();
                },
                iconSize: 48,
              ),
              // 快进 10 秒
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                onPressed: () {
                  _playerService.forward(const Duration(seconds: 10));
                },
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          // 附加控制
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 音量控制
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _playerService.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _playerService.toggleMute();
                    },
                  ),
                  SizedBox(
                    width: 80,
                    child: Slider(
                      value: _playerService.volume,
                      onChanged: (value) {
                        _playerService.setVolume(value);
                      },
                      activeColor: Colors.white,
                    ),
                  ),
                ],
              ),
              // 播放速度
              TextButton(
                onPressed: _showSpeedMenu,
                child: Text(
                  '${_playerService.speed}x',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              // 字幕
              IconButton(
                icon: const Icon(Icons.subtitles, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('字幕功能请稍后使用...')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  Widget buildProgressBar() {
    return Row(
      children: [
        Text(
          _formatDuration(_playerService.position),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: Colors.white30,
              thumbColor: Colors.white,
              trackHeight: 4,
            ),
            child: Slider(
              value: _playerService.position.inSeconds.toDouble(),
              max: _playerService.duration.inSeconds.toDouble() > 0 
                  ? _playerService.duration.inSeconds.toDouble() 
                  : 1,
              onChanged: (value) {
                _playerService.seekTo(Duration(seconds: value.toInt()));
                setState(() {});
              },
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Text(
          _formatDuration(_playerService.duration),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.hd),
              title: const Text('画质'),
              subtitle: const Text('原始'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('画质选择功能开发中...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.subtitles),
              title: const Text('字幕'),
              subtitle: const Text('自动'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('字幕功能开发中...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('播放速度'),
              subtitle: Text('${_playerService.speed}x'),
              onTap: () {
                Navigator.pop(context);
                _showSpeedMenu();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '播放速度',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            ...const [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
              return ListTile(
                leading: Icon(
                  _playerService.speed == speed 
                      ? Icons.check 
                      : Icons.speed,
                  color: _playerService.speed == speed 
                      ? AppTheme.primaryColor 
                      : null,
                ),
                title: Text('${speed}x'),
                onTap: () {
                  _playerService.setSpeed(speed);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
