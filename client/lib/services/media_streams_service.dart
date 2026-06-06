import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

class MediaStreamInfo {
  final int index;
  final String type;
  final String? displayTitle;
  final String? language;
  final String? title;
  final bool isDefault;
  final bool isForced;
  final bool isExternal;
  final String? codec;
  final String? profile;
  final String? path;
  final String? deliveryUrl;

  MediaStreamInfo({
    required this.index,
    required this.type,
    this.displayTitle,
    this.language,
    this.title,
    this.isDefault = false,
    this.isForced = false,
    this.isExternal = false,
    this.codec,
    this.profile,
    this.path,
    this.deliveryUrl,
  });

  factory MediaStreamInfo.fromJson(Map<String, dynamic> json) {
    return MediaStreamInfo(
      index: json['Index'] ?? 0,
      type: json['Type'] ?? 'unknown',
      displayTitle: json['DisplayTitle'],
      language: json['Language'],
      title: json['Title'],
      isDefault: json['IsDefault'] ?? false,
      isForced: json['IsForced'] ?? false,
      isExternal: json['IsExternal'] ?? false,
      codec: json['Codec'],
      profile: json['Profile'],
      path: json['Path'],
      deliveryUrl: json['DeliveryUrl'],
    );
  }

  String get displayName {
    if (displayTitle != null && displayTitle!.isNotEmpty) {
      return displayTitle!;
    }
    final parts = <String>[];
    if (title != null && title!.isNotEmpty) parts.add(title!);
    if (language != null && language!.isNotEmpty) parts.add(language!.toUpperCase());
    if (codec != null && codec!.isNotEmpty) parts.add(codec!.toUpperCase());
    return parts.isNotEmpty ? parts.join(' - ') : '轨道 ${index + 1}';
  }
}

class MediaStreamsService {
  final String baseUrl;
  final String? apiKey;

  MediaStreamsService({
    required this.baseUrl,
    this.apiKey,
  });

  /// 获取字幕列表
  List<MediaStreamInfo> getSubtitleStreams(List<MediaStreamInfo> allStreams) {
    return allStreams.where((s) => s.type == 'Subtitle').toList();
  }

  /// 获取音轨列表
  List<MediaStreamInfo> getAudioStreams(List<MediaStreamInfo> allStreams) {
    return allStreams.where((s) => s.type == 'Audio').toList();
  }

  /// 从播放信息中提取媒体流
  List<MediaStreamInfo> extractMediaStreams(Map<String, dynamic> playbackInfo) {
    final mediaSources = playbackInfo['MediaSources'] as List?;
    if (mediaSources == null || mediaSources.isEmpty) return [];

    final mediaSource = mediaSources.first;
    final streams = mediaSource['MediaStreams'] as List?;
    if (streams == null) return [];

    return streams.map((s) => MediaStreamInfo.fromJson(s)).toList();
  }

  /// 获取外部字幕 URL
  String getSubtitleDeliveryUrl({
    required String itemId,
    required int streamIndex,
    required String streamId,
  }) {
    if (apiKey != null) {
      return '$baseUrl/Videos/$itemId/$streamId/Subtitles/$streamIndex/Stream.{format}?api_key=$apiKey';
    }
    return '$baseUrl/Videos/$itemId/$streamId/Subtitles/$streamIndex/Stream.{format}';
  }

  /// 切换音轨（通过更新播放会话）
  Future<void> switchAudioStream({
    required String itemId,
    required int streamIndex,
    String? playSessionId,
  }) async {
    try {
      // Emby 音轨切换通常需要在播放时通过 session 控制
      // 这里提供基础实现，具体取决于播放器支持
      final url = Uri.parse('$baseUrl/Sessions/Playing/PlaybackRate');
      await http.post(url, headers: {
        'X-Emby-Authorization': _buildAuthHeader(),
        'Content-Type': 'application/json',
      });
    } catch (e) {
      print('切换音轨失败：$e');
    }
  }

  /// 加载外部字幕
  Future<String?> loadExternalSubtitle({
    required String itemId,
    required int streamIndex,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/Videos/$itemId/Subtitles/$streamIndex/Stream.vtt?api_key=$apiKey',
      );
      final response = await http.get(url, headers: {
        'X-Emby-Authorization': _buildAuthHeader(),
      });

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print('加载字幕失败：$e');
    }
    return null;
  }

  /// 获取字幕格式
  String getSubtitleFormat(String codec) {
    switch (codec?.toLowerCase()) {
      case 'subrip':
        return 'srt';
      case 'webvtt':
        return 'vtt';
      case 'ass':
      case 'ssa':
        return 'ass';
      default:
        return 'srt';
    }
  }

  /// 转换 SRT 到 WebVTT
  String convertSrtToVtt(String srtContent) {
    final lines = srtContent.split('\n');
    final vttLines = <String>['WEBVTT', ''];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // 序号行
      if (RegExp(r'^\d+$').hasMatch(line)) {
        continue;
      }

      // 时间行转换
      final timeMatch = RegExp(r'(\d{2}):(\d{2}):(\d{2}),(\d{3}) --> (\d{2}):(\d{2}):(\d{2}),(\d{3})')
          .firstMatch(line);
      if (timeMatch != null) {
        final vttTime = line.replaceAll(',', '.');
        vttLines.add(vttTime);
        continue;
      }

      // 字幕文本
      vttLines.add(line);
    }

    return vttLines.join('\n');
  }

  String _buildAuthHeader() {
    return 'MediaBrowser Client="E 宝盒", Version="5.0.0", Token="$apiKey"';
  }
}
