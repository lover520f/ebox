import 'package:flutter/material.dart';
import '../services/video_player_service.dart';

/// iOS 优化的播放器手势覆盖层
/// 支持滑动快进/快退、双击播放/暂停
class GesturePlayerOverlay extends StatefulWidget {
  final VideoPlayerService player;
  final Widget child;

  const GesturePlayerOverlay({
    Key? key,
    required this.player,
    required this.child,
  }) : super(key: key);

  @override
  State<GesturePlayerOverlay> createState() => _GesturePlayerOverlayState();
}

class _GesturePlayerOverlayState extends State<GesturePlayerOverlay> {
  double _dragStartX = 0;
  Duration? _dragStartPosition;
  Duration? _dragCurrentPosition;
  bool _isDragging = false;
  int _tapCount = 0;
  Timer? _tapTimer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTap: _onTap,
      onDoubleTap: _onDoubleTap,
      child: Stack(
        children: [
          widget.child,
          // 拖动手势反馈
          if (_isDragging) _buildDragOverlay(),
        ],
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStartX = details.globalPosition.dx;
      _dragStartPosition = widget.player.position;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || _dragStartPosition == null) return;

    final delta = details.globalPosition.dx - _dragStartX;
    final sensitivity = 10000; // 每滑动 1 像素 = 10ms
    final offset = Duration(milliseconds: (delta * 10).round());
    
    setState(() {
      _dragCurrentPosition = _dragStartPosition! + offset;
      if (_dragCurrentPosition! < Duration.zero) {
        _dragCurrentPosition = Duration.zero;
      }
      if (_dragCurrentPosition! > widget.player.duration) {
        _dragCurrentPosition = widget.player.duration;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragCurrentPosition != null) {
      widget.player.seekTo(_dragCurrentPosition!);
    }

    setState(() {
      _isDragging = false;
      _dragCurrentPosition = null;
    });
  }

  void _onTap() {
    _tapCount++;
    
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(milliseconds: 300), () {
      if (_tapCount == 1) {
        // 单击：显示控制栏
        widget.player.togglePlayPause();
      }
      _tapCount = 0;
    });
  }

  void _onDoubleTap() {
    _tapTimer?.cancel();
    _tapCount = 0;
    
    // 双击：快进 10 秒
    final newPosition = widget.player.position + const Duration(seconds: 10);
    if (newPosition < widget.player.duration) {
      widget.player.seekTo(newPosition);
    }
  }

  Widget _buildDragOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fiber_manual_record,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _formatDuration(_dragCurrentPosition ?? Duration.zero),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }
}
