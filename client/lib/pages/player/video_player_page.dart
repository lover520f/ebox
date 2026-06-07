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
  bool _isReady = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final server = context.read<ServerProvider>().activeServer;
    if (server == null) {
      setState(() {
        _error = '未连接服务器';
        _isLoading = false;
      });
      return;
    }

    try {
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

      final container = mediaSources.first['Container'] as String? ?? 'mp4';
      final videoUrl = '${server.url}/Videos/${widget.itemId}/stream.$container?api_key=${server.apiKey}';

      print('播放地址：$videoUrl');

      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _controller!.initialize();

      setState(() {
        _isLoading = false;
        _isReady = true;
      });

      _controller!.play();
    } catch (e) {
      setState(() {
        _error = '播放失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_error != null || !_isReady) {
      return _buildError();
    }

    return _buildPlayer();
  }

  Widget _buildLoading() {
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

  Widget _buildError() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 24),
            Text(
              _error ?? '未知错误',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
              ),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
          if (!_controller!.value.isPlaying)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
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
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: const Color(0xFF6C5CE7),
                bufferedColor: Colors.white30,
                backgroundColor: Colors.white20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
