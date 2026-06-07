import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../services/emby_api_service.dart';
import '../../providers/server_provider.dart';

class VideoPlayerPage extends StatefulWidget {
  final String itemId;
  final String title;

  const VideoPlayerPage({
    Key? key,
    required this.itemId,
    required this.title,
  }) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _setupKeyboard();
  }

  Future<void> _initPlayer() async {
    try {
      final server = context.read<ServerProvider>().activeServer;
      if (server == null) {
        setState(() {
          _error = '未连接服务器';
          _isLoading = false;
        });
        return;
      }

      final api = EmbyApiService(
        baseUrl: server.url,
        apiKey: server.apiKey,
        userId: '1',
      );

      final playbackInfo = await api.getPlaybackInfo(widget.itemId);
      
      if (playbackInfo == null) {
        setState(() {
          _error = '无法获取播放信息';
          _isLoading = false;
        });
        return;
      }

      final mediaSources = playbackInfo['MediaSources'] as List?;
      if (mediaSources == null || mediaSources.isEmpty) {
        setState(() {
          _error = '无可用媒体源';
          _isLoading = false;
        });
        return;
      }

      final mediaSource = mediaSources.first;
      String? videoUrl = mediaSource['DirectStreamUrl'] as String?;
      
      if (videoUrl == null || videoUrl.isEmpty) {
        final container = mediaSource['Container'] as String?;
        if (container != null) {
          videoUrl = '${server.url}/Videos/${widget.itemId}/stream.$container?api_key=${server.apiKey}';
        }
      }

      if (videoUrl == null || !videoUrl.startsWith('http')) {
        videoUrl = '${server.url}/Videos/${widget.itemId}/stream?api_key=${server.apiKey}';
      }

      print('播放地址：$videoUrl');

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      )..initialize().then((_) {
        setState(() {
          _isLoading = false;
          _duration = _controller!.duration;
        });
        _controller!.play();
        setState(() => _isPlaying = true);
      }).catchError((e) {
        setState(() {
          _error = '播放失败：$e';
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _error = '初始化失败：$e';
        _isLoading = false;
      });
    }
  }

  void _setupKeyboard() {
    RawKeyboard.instance.addListener((event) {
      if (event is! KeyDownEvent) return;

      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _exitPlayer();
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _togglePlay();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _seekRelative(-10);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _seekRelative(10);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _changeVolume(0.1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _changeVolume(-0.1);
      }
    });
  }

  void _exitPlayer() {
    _controller?.pause();
    Navigator.of(context).pop();
  }

  void _togglePlay() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _seekRelative(int seconds) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final newPos = _position + Duration(seconds: seconds);
    if (newPos < Duration.zero) {
      _controller!.seekTo(Duration.zero);
    } else if (newPos > _duration) {
      _controller!.seekTo(_duration);
    } else {
      _controller!.seekTo(newPos);
    }
  }

  void _changeVolume(double delta) {
    // TODO: 实现音量控制
  }

  @override
  void dispose() {
    _controller?.dispose();
    RawKeyboard.instance.removeHandler((event) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_error != null) {
      return _buildErrorScreen();
    }

    return _buildPlayerScreen();
  }

  Widget _buildLoadingScreen() {
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
              '正在加载 ${widget.title}...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 24),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _exitPlayer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          VideoProgressIndicator(
            _controller!,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: const Color(0xFF6C5CE7),
              bufferedColor: Colors.white30,
              backgroundColor: Colors.white20,
            ),
            padding: const EdgeInsets.all(20),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: _exitPlayer,
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!_isPlaying)
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
