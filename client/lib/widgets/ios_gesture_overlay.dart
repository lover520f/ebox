import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/video_player_service.dart';

class IosGestureOverlay extends StatefulWidget {
  final VideoPlayerService player;
  final VoidCallback onBack;
  final String title;

  const IosGestureOverlay({
    Key? key,
    required this.player,
    required this.onBack,
    required this.title,
  }) : super(key: key);

  @override
  State<IosGestureOverlay> createState() => _IosGestureOverlayState();
}

class _IosGestureOverlayState extends State<IosGestureOverlay> {
  double _brightness = 0.5;
  double _volume = 0.5;
  bool _showControls = false;
  Duration _gesturePosition = Duration.zero;
  String _gestureType = '';

  @override
  void initState() {
    super.initState();
    _volume = widget.player.volume;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 全屏手势区域
        GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          onTapDown: _onTap,
          onDoubleTap: _onDoubleTap,
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // 左侧亮度控制提示
        if (_gestureType == 'brightness')
          Positioned(
            left: 20,
            top: MediaQuery.of(context).size.height / 2 - 100,
            child: _buildGestureIndicator(
              Icons.brightness_7,
              '${(_brightness * 100).round()}%',
              _brightness,
            ),
          ),

        // 右侧音量控制提示
        if (_gestureType == 'volume')
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 100,
            child: _buildGestureIndicator(
              widget.player.isMuted ? Icons.volume_off : Icons.volume_up,
              '${(_volume * 100).round()}%',
              _volume,
            ),
          ),

        // 中央播放位置提示
        if (_gestureType == 'seek')
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height / 2 - 60,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _gesturePosition.inSeconds > 0 
                          ? Icons.fast_forward 
                          : Icons.fast_rewind,
                      color: const Color(0xFF6C5CE7),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_gesturePosition.inSeconds.abs()}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 顶部控制栏
        AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              bottom: 10,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onBack,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 中央播放/暂停按钮
        if (!widget.player.isPlaying)
          Center(
            child: GestureDetector(
              onTap: widget.player.togglePlayPause,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),

        // 底部进度条
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          bottom: _showControls ? 0 : -100,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSeekBar(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.player.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                          onPressed: widget.player.togglePlayPause,
                        ),
                        IconButton(
                          icon: const Icon(Icons.replay_10_rounded, size: 32, color: Colors.white),
                          onPressed: () => widget.player.rewind(const Duration(seconds: 10)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, size: 32, color: Colors.white),
                          onPressed: () => widget.player.forward(const Duration(seconds: 10)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            '${_formatDuration(widget.player.position)} / ${_formatDuration(widget.player.duration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.player.isMuted || widget.player.volume == 0
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: Colors.white,
                          ),
                          onPressed: widget.player.toggleMute,
                        ),
                        SizedBox(
                          width: 100,
                          child: Slider(
                            value: widget.player.volume,
                            min: 0,
                            max: 1,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white30,
                            onChanged: (value) => widget.player.setVolume(value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGestureIndicator(IconData icon, String label, double value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF6C5CE7), size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          RotatedBox(
            quarterTurns: 3,
            child: SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekBar() {
    final duration = widget.player.duration;
    final position = widget.player.position;

    if (duration.inMilliseconds == 0) return const SizedBox(height: 4);

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        activeTrackColor: const Color(0xFF6C5CE7),
        inactiveTrackColor: Colors.white30,
        thumbColor: const Color(0xFF6C5CE7),
      ),
      child: Slider(
        value: position.inMilliseconds.toDouble(),
        min: 0,
        max: duration.inMilliseconds.toDouble(),
        onChanged: (value) {
          widget.player.seekTo(Duration(milliseconds: value.toInt()));
        },
      ),
    );
  }

  void _onTap(TapDownDetails details) {
    setState(() => _showControls = !_showControls);
  }

  void _onDoubleTap() {
    widget.player.togglePlayPause();
  }

  void _onDragStart(DragStartDetails details) {
    _gesturePosition = Duration.zero;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = details.delta.dx;
    final seekSeconds = (delta / 100).round();
    setState(() {
      _gesturePosition = Duration(seconds: seekSeconds);
      _gestureType = 'seek';
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_gestureType == 'seek' && _gesturePosition.inSeconds != 0) {
      final newPosition = widget.player.position + _gesturePosition;
      widget.player.seekTo(newPosition);
    }
    setState(() {
      _gestureType = '';
      _gesturePosition = Duration.zero;
    });
  }

  void _onVerticalDragStart(VerticalDragStartDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final touchX = details.localPosition.dx;

    if (touchX < screenWidth / 2) {
      _gestureType = 'brightness';
    } else {
      _gestureType = 'volume';
      _volume = widget.player.volume;
    }
  }

  void _onVerticalDragUpdate(VerticalDragUpdateDetails details) {
    final delta = details.delta.dy / 500;

    if (_gestureType == 'brightness') {
      setState(() {
        _brightness = (_brightness - delta).clamp(0.0, 1.0);
      });
      SystemChrome.setSystemUIOverlayStyle(
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.light,
        ),
      );
    } else if (_gestureType == 'volume') {
      setState(() {
        _volume = (_volume - delta).clamp(0.0, 1.0);
      });
      widget.player.setVolume(_volume);
    }
  }

  void _onVerticalDragEnd(VerticalDragEndDetails details) {
    setState(() => _gestureType = '');
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
