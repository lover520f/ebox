import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../services/video_player_service.dart';
import '../../services/emby_api_client.dart';
import '../../widgets/advanced_player_controls.dart';

/// 完整的视频播放页面
/// 支持全屏、播放报告、快捷键控制
class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String itemId;
  final String title;

  const VideoPlayerPage({
    Key? key,
    required this.videoUrl,
    required this.itemId,
    required this.title,
  }) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerService _player;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _setupKeyboardShortcuts();
  }

  Future<void> _initializePlayer() async {
    _player = context.read<VideoPlayerService>();
    
    // 设置 API 客户端用于播放报告
    final embyClient = context.read<EmbyApiClient>();
    _player.setApiClient(embyClient);
    
    // 进入全屏模式
    await _enterFullScreen();
    
    // 隐藏系统 UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // 初始化视频
    try {
      await _player.initialize(widget.videoUrl, itemId: widget.itemId);
      await _player.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放失败：$e')),
        );
      }
    }
  }

  void _setupKeyboardShortcuts() {
    RawKeyboard.instance.addListener((event) {
      if (!_player.isInitialized) return;
      
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
        if (_isFullScreen) {
          _exitFullScreen();
        } else {
          Navigator.of(context).pop();
        }
        return;
      }
      
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
        _player.togglePlayPause();
        return;
      }
      
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _player.rewind(const Duration(seconds: 10));
        return;
      }
      
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _player.forward(const Duration(seconds: 10));
        return;
      }
      
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _player.setVolume(_player.volume + 0.1);
        return;
      }
      
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _player.setVolume(_player.volume - 0.1);
        return;
      }
    });
  }

  Future<void> _enterFullScreen() async {
    setState(() {
      _isFullScreen = true;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _exitFullScreen() async {
    setState(() {
      _isFullScreen = false;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Consumer<VideoPlayerService>(
                builder: (context, player, _) {
                  if (!player.isVideoInitialized) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return VideoPlayer(_player.controller!);
                },
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0),
                    Colors.black.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      _exitFullScreen();
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AdvancedPlayerControls(),
          ),
          Consumer<VideoPlayerService>(
            builder: (context, player, _) {
              if (!player.isInitialized || !player.isVideoInitialized) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
