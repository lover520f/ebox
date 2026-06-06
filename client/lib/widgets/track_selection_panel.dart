import 'package:flutter/material.dart';
import '../services/media_streams_service.dart';

class TrackSelectionPanel extends StatelessWidget {
  final List<MediaStreamInfo> audioTracks;
  final List<MediaStreamInfo> subtitleTracks;
  final int? selectedAudioIndex;
  final int? selectedSubtitleIndex;
  final ValueChanged<int>? onAudioSelected;
  final ValueChanged<int>? onSubtitleSelected;
  final VoidCallback? onClose;

  const TrackSelectionPanel({
    Key? key,
    required this.audioTracks,
    required this.subtitleTracks,
    this.selectedAudioIndex,
    this.selectedSubtitleIndex,
    this.onAudioSelected,
    this.onSubtitleSelected,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '音轨和字幕',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: onClose,
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          _buildSectionTitle('音轨'),
          const SizedBox(height: 8),
          ...audioTracks.map((track) => _buildTrackItem(
                title: track.displayName,
                isSelected: selectedAudioIndex == track.index,
                onTap: () => onAudioSelected?.call(track.index),
                icon: Icons.volume_up,
              )),
          if (audioTracks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '无可用音轨',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          const SizedBox(height: 20),
          _buildSectionTitle('字幕'),
          const SizedBox(height: 8),
          ...subtitleTracks.map((track) => _buildTrackItem(
                title: track.displayName,
                isSelected: selectedSubtitleIndex == track.index,
                onTap: () => onSubtitleSelected?.call(track.index),
                icon: Icons.subtitles,
                hasExternal: track.isExternal,
              )),
          _buildTrackItem(
            title: '关闭字幕',
            isSelected: selectedSubtitleIndex == -1,
            onTap: () => onSubtitleSelected?.call(-1),
            icon: Icons.subtitles_off,
          ),
          if (subtitleTracks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '无可用字幕',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTrackItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    bool hasExternal = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5CE7).withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[300],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasExternal) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00CEC9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '外部',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6C5CE7),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
