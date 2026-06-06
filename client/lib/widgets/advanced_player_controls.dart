import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/video_player_service.dart';
import '../services/media_streams_service.dart';
import 'track_selection_panel.dart';

class AdvancedPlayerControls extends StatefulWidget {
  final VideoPlayerService player;
  final VoidCallback onBack;
  final String title;

  const AdvancedPlayerControls({
    Key? key,
    required this.player,
    required this.onBack,
    required this.title,
  }) : super(key: key);

  @override
  State<AdvancedPlayerControls> createState() => _AdvancedPlayerControlsState();
}

class _AdvancedPlayerControlsState extends State<AdvancedPlayerControls> {
  bool _isControlsVisible = true;
  Timer? _hideTimer;
  bool _showTrackPanel = false;
  List<MediaStreamInfo> _audioTracks = [];
  List<MediaStreamInfo> _subtitleTracks = [];
  int? _selectedAudioIndex;
  int? _selectedSubtitleIndex;

  @override
  void initState() {
    super.initState();
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_showTrackPanel) {
        setState(() => _isControlsVisible = false);
      }
    });
  }

  void _onInteraction() {
    setState(() {
      _isControlsVisible = true;
      _showTrackPanel = false;
    });
    _resetHideTimer();
  }

  void _toggleTrackPanel() {
    setState(() {
      _showTrackPanel = !_showTrackPanel;
      if (_showTrackPanel) {
        _hideTimer?.cancel();
      } else {
        _resetHideTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onInteraction,
      child: Stack(
        children: [
          // 顶部栏
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _isControlsVisible || _showTrackPanel ? 0 : -100,
            left: 0,
            right: 0,
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
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(
                      _showTrackPanel ? Icons.subtitles : Icons.subtitles_outlined,
                      color: _showTrackPanel ? const Color(0xFF6C5CE7) : Colors.white,
                    ),
                    onPressed: _toggleTrackPanel,
                    tooltip: '音轨和字幕',
                  ),
                ],
              ),
            ),
          ),

          // 中央播放/暂停按钮
          if (!widget.player.isPlaying && _isControlsVisible && !_showTrackPanel)
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

          // 底部控制栏
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _isControlsVisible || _showTrackPanel ? 0 : -200,
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
                          IconButton(
                            icon: const Icon(Icons.aspect_ratio_rounded, color: Colors.white),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                            },
                            tooltip: '画面比例',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 音轨和字幕选择面板
          if (_showTrackPanel)
            Center(
              child: TrackSelectionPanel(
                audioTracks: _audioTracks,
                subtitleTracks: _subtitleTracks,
                selectedAudioIndex: _selectedAudioIndex,
                selectedSubtitleIndex: _selectedSubtitleIndex,
                onAudioSelected: (index) {
                  setState(() => _selectedAudioIndex = index);
                  _toggleTrackPanel();
                },
                onSubtitleSelected: (index) {
                  setState(() => _selectedSubtitleIndex = index);
                  if (index >= 0 && index <= _subtitleTracks.length) {
                    _loadSubtitle(index);
                  }
                  _toggleTrackPanel();
                },
                onClose: _toggleTrackPanel,
              ),
            ),

          // 播放状态提示
          Positioned(
            top: 100,
            right: 20,
            child: _buildPlaybackSpeedIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekBar() {
    final duration = widget.player.duration;
    final position = widget.player.position;

    if (duration.inMilliseconds == 0) {
      return const SizedBox(height: 4);
    }

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            activeTrackColor: const Color(0xFF6C5CE7),
            inactiveTrackColor: Colors.white30,
            thumbColor: const Color(0xFF6C5CE7),
            overlayColor: const Color(0xFF6C5CE7).withOpacity(0.1),
          ),
          child: Slider(
            value: position.inMilliseconds.toDouble(),
            min: 0,
            max: duration.inMilliseconds.toDouble(),
            onChanged: (value) {
              widget.player.seekTo(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackSpeedIndicator() {
    return StreamBuilder<double>(
      stream: widget.player.playbackSpeedStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == 1.0) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${snapshot.data!.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadSubtitle(int trackIndex) async {
    if (trackIndex < 0 || trackIndex >= _subtitleTracks.length) return;

    final track = _subtitleTracks[trackIndex];
    print('加载字幕：${track.displayName}');
    // TODO: 实际加载字幕并应用到播放器
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
