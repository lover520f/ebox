import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/video_player_service.dart';
import 'package:intl/intl.dart';

class AdvancedPlayerControls extends StatefulWidget {
  const AdvancedPlayerControls({Key? key}) : super(key: key);

  @override
  State<AdvancedPlayerControls> createState() => _AdvancedPlayerControlsState();
}

class _AdvancedPlayerControlsState extends State<AdvancedPlayerControls> {
  bool _isControlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _onInteraction() {
    setState(() {
      _isControlsVisible = true;
    });
    _resetHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPlayerService>(
      builder: (context, player, child) {
        if (!player.isInitialized) return const SizedBox.shrink();

        return GestureDetector(
          onTap: _onInteraction,
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: (!player.isPlaying && _isControlsVisible) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: IconButton(
                    iconSize: 64,
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    onPressed: player.togglePlayPause,
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: _isControlsVisible ? 0 : -200,
                left: 0,
                right: 0,
                child: Container(
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSeekBar(player),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  player.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                onPressed: player.togglePlayPause,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.replay_10_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                onPressed: () => player.rewind(const Duration(seconds: 10)),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.forward_10_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                onPressed: () => player.forward(const Duration(seconds: 10)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  '${_formatDuration(player.position)} / ${_formatDuration(player.duration)}',
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
                              Icon(
                                player.isMuted || player.volume == 0
                                    ? Icons.volume_off_rounded
                                    : Icons.volume_up_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 100,
                                child: Slider(
                                  value: player.volume,
                                  min: 0,
                                  max: 1,
                                  activeColor: Colors.white,
                                  onChanged: (value) => player.setVolume(value),
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
          ),
        );
      },
    );
  }

  Widget _buildSeekBar(VideoPlayerService player) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
      ),
      child: Slider(
        value: player.position.inMilliseconds.toDouble(),
        max: player.duration.inMilliseconds.toDouble(),
        activeColor: Colors.blueAccent,
        inactiveColor: Colors.white38,
        onChanged: (value) {
          player.seekTo(Duration(milliseconds: value.toInt()));
          _resetHideTimer();
        },
        onChangeEnd: (value) {
          _resetHideTimer();
        },
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
    _hideTimer?.cancel();
    super.dispose();
  }
}
