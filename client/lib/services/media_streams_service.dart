import 'package:flutter/foundation.dart';

/// 媒体流服务
/// 管理字幕、音轨、画质选择
class MediaStreamsService extends ChangeNotifier {
  List<SubtitleStream> _subtitles = [];
  List<AudioStream> _audioTracks = [];
  SubtitleStream? _currentSubtitle;
  AudioStream? _currentAudio;

  List<SubtitleStream> get subtitles => List.unmodifiable(_subtitles);
  List<AudioStream> get audioTracks => List.unmodifiable(_audioTracks);
  SubtitleStream? get currentSubtitle => _currentSubtitle;
  AudioStream? get currentAudio => _currentAudio;

  void setStreams({
    List<SubtitleStream> subtitles = const [],
    List<AudioStream> audioTracks = const [],
  }) {
    _subtitles = subtitles;
    _audioTracks = audioTracks;
    notifyListeners();
  }

  void selectSubtitle(SubtitleStream? subtitle) {
    _currentSubtitle = subtitle;
    notifyListeners();
    // TODO: 实际切换字幕流
  }

  void selectAudio(AudioStream audio) {
    _currentAudio = audio;
    notifyListeners();
    // TODO: 实际切换音轨
  }

  SubtitleStream? get defaultSubtitle =>
      _subtitles.cast<SubtitleStream?>().firstWhere(
        (s) => s?.isDefault == true,
        orElse: () => null,
      );

  AudioStream? get defaultAudio =>
      _audioTracks.cast<AudioStream?>().firstWhere(
        (a) => a?.isDefault == true,
        orElse: () => null,
      );
}

class SubtitleStream {
  final String id;
  final String language;
  final String? title;
  final String? codec;
  final bool isExternal;
  final bool isDefault;
  final bool isForced;

  SubtitleStream({
    required this.id,
    required this.language,
    this.title,
    this.codec,
    this.isExternal = false,
    this.isDefault = false,
    this.isForced = false,
  });

  String get displayName {
    if (title != null && title!.isNotEmpty) {
      return '$language - $title';
    }
    return language;
  }

  factory SubtitleStream.fromJson(Map<String, dynamic> json) {
    return SubtitleStream(
      id: json['Id']?.toString() ?? '',
      language: json['Language'] ?? 'Unknown',
      title: json['Title'],
      codec: json['Codec'],
      isExternal: json['IsExternal'] == true,
      isDefault: json['IsDefault'] == true,
      isForced: json['IsForced'] == true,
    );
  }
}

class AudioStream {
  final String id;
  final String language;
  final String? title;
  final String? codec;
  final int? channels;
  final bool isDefault;

  AudioStream({
    required this.id,
    required this.language,
    this.title,
    this.codec,
    this.channels,
    this.isDefault = false,
  });

  String get displayName {
    final buffer = StringBuffer(language);
    if (codec != null) {
      buffer.write(' - $codec');
    }
    if (channels != null) {
      buffer.write(' ${channels}ch');
    }
    if (title != null && title!.isNotEmpty) {
      buffer.write(' ($title)');
    }
    return buffer.toString();
  }

  factory AudioStream.fromJson(Map<String, dynamic> json) {
    return AudioStream(
      id: json['Id']?.toString() ?? '',
      language: json['Language'] ?? 'Unknown',
      title: json['Title'],
      codec: json['Codec'],
      channels: json['Channels'],
      isDefault: json['IsDefault'] == true,
    );
  }
}
