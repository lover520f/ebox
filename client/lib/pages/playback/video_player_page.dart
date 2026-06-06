import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../models/media_item.dart';
import '../../services/video_player_service.dart';
import '../../services/emby_api_client.dart';
import '../../widgets/advanced_player_controls.dart';

class VideoPlayerPage extends StatefulWidget {
  final MediaItem item;
  final int playPosition;

  const VideoPlayerPage({
    Key? key,
    required this.item,
    this.playPosition = 0,
  }) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerService _player;
  bool _isFullScreen = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _setupKeyboardShortcuts();
  }

  Future<void> _initializePlayer() async {
    _player = context.read<VideoPlayerService>();
    
    final embyClient = context.read<EmbyApiClient>();
    _player.setApiClient(embyClient);
    
    await _enterFullScreen();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    try {
      final playbackInfo = await embyClient.getPlaybackInfo(widget.item.id);
      
      if (playbackInfo == null) {
        setState(() {
          _errorMessage = '无法获取播放信息';
          _isLoading = false;
        });
        return;
      }
      
      final mediaSources = playbackInfo['MediaSources'] as List?;
      if (mediaSources == null || mediaSources.isEmpty) {
        setState(() {
          _errorMessage = '无可用媒体源';
          _isLoading = false;
        });
        return;
      }
      
      final mediaSource = mediaSources.first;
      final playUrl = mediaSource['DirectStreamUrl'] as String? ?? 
                      mediaSource['TranscodingUrl'] as String?;
      
      if (playUrl == null) {
        setState(() {
          _errorMessage = '无法获取播放地址';
          _isLoading = false;
        });
        return;
      }
      
      final fullUrl = playUrl.startsWith('http') 
          ? playUrl 
          : '${embyClient.baseUrl}$playUrl';
      
      await _player.initialize(fullUrl, itemId: widget.item.id);
      await _player.play();
      
      if (widget.playPosition > 0) {
        final position = Duration(microseconds: widget.playPosition ~/ 10);
        await _player.seekTo(position);
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '播放失败：$e';
          _isLoading = false;
        });
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
          _handleBack();
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
      
      if (event is RawKeyDownEvent && 
          (event.logicalKey == LogicalKeyboardKey.keyM || 
           event.logicalKey == LogicalKeyboardKey.keyK)) {
        _player.toggleMute();
        return;
      }
      
      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyF) {
        if (_isFullScreen) {
          _exitFullScreen();
        } else {
          _enterFullScreen();
        }
        return;
      }
    });
  }

  Future<void> _enterFullScreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() => _isFullScreen = true);
  }

  Future<void> _exitFullScreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    setState(() => _isFullScreen = false);
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
              const SizedBox(height: 24),
              Text(
                '正在加载 ${widget.item.name}...',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _handleBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _player.aspectRatio ?? 16 / 9,
              child: VideoPlayer(_player.controller),
            ),
          ),
          AdvancedPlayerControls(
            player: _player,
            onBack: _handleBack,
            title: widget.item.name,
          ),
        ],
      ),
    );
  }
}
