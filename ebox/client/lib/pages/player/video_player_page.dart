import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/player_provider.dart';
import '../../providers/server_provider.dart';

class VideoPlayerPage extends StatefulWidget {
  final String itemId;
  final String serverId;

  const VideoPlayerPage({
    super.key,
    required this.itemId,
    required this.serverId,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  bool _isPlaying = false;
  bool _showControls = true;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;
  double _playbackSpeed = 1.0;
  
  DateTime _lastInteractionTime = DateTime.now();
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    // TODO: 初始化视频播放器
    // 这里会集成 video_player 或 fijkplayer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 模拟加载
      setState(() {
        _duration = const Duration(hours: 1, minutes: 30);
      });
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    super.dispose();
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _lastInteractionTime = DateTime.now();
    
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 视频区域 (占位)
          buildVideoArea(),
          
          // 顶部控制栏
          if (_showControls) buildTopBar(),
          
          // 底部控制栏
          if (_showControls) buildBottomBar(),
          
          // 中央播放/暂停按钮
          if (!_showControls && _isPlaying)
            Positioned.fill(
              child: GestureDetector(
                onTap: _showControlsTemporarily,
                child: Container(),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildVideoArea() {
    return GestureDetector(
      onTap: _showControlsTemporarily,
      onDoubleTap: _togglePlayPause,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 播放图标 (占位)
              Icon(
                _isPlaying ? Icons.play_arrow : Icons.pause,
                size: 100,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                '视频播放器开发中',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Item ID: ${widget.itemId}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
          const Expanded(
            child: Text(
              '视频播放',
              style: TextStyle(
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
          const SizedBox(width: AppTheme.spacingS),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {
              // TODO: 切换全屏
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
                  _seekBackward();
                },
                iconSize: 32,
              ),
              // 播放/暂停
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: _togglePlayPause,
                iconSize: 48,
              ),
              // 快进 10 秒
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                onPressed: () {
                  _seekForward();
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
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _isMuted = !_isMuted);
                    },
                  ),
                  SizedBox(
                    width: 80,
                    child: Slider(
                      value: _isMuted ? 0 : _volume,
                      onChanged: (value) {
                        setState(() {
                          _volume = value;
                          _isMuted = value == 0;
                        });
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
                  '${_playbackSpeed}x',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              // 字幕
              IconButton(
                icon: const Icon(Icons.subtitles, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('字幕功能开发中...')),
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
          _formatDuration(_position),
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
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble() > 0 
                  ? _duration.inSeconds.toDouble() 
                  : 1,
              onChanged: (value) {
                setState(() {
                  _position = Duration(seconds: value.toInt());
                });
              },
              onChangeEnd: (value) {
                _seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Text(
          _formatDuration(_duration),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _showControlsTemporarily();
    }
  }

  void _seekBackward() {
    final newPosition = _position - const Duration(seconds: 10);
    if (newPosition.inSeconds < 0) {
      _seekTo(Duration.zero);
    } else {
      _seekTo(newPosition);
    }
  }

  void _seekForward() {
    final newPosition = _position + const Duration(seconds: 10);
    if (newPosition.inSeconds > _duration.inSeconds) {
      _seekTo(_duration);
    } else {
      _seekTo(newPosition);
    }
  }

  void _seekTo(Duration position) {
    setState(() {
      _position = position;
    });
    // TODO: 实际播放器 seek 操作
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
              subtitle: const Text('未加载'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('字幕选择功能开发中...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('播放速度'),
              subtitle: Text('${_playbackSpeed}x'),
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
                  _playbackSpeed == speed ? Icons.check : Icons.speed,
                  color: _playbackSpeed == speed 
                      ? AppTheme.primaryColor 
                      : null,
                ),
                title: Text('${speed}x'),
                onTap: () {
                  setState(() => _playbackSpeed = speed);
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
