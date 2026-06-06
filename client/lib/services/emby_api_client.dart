import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../models/user_view.dart';
import '../models/search_result.dart';

class EmbyApiClient {
  final String baseUrl;
  final String? apiKey;
  final String? userId;
  final String? username;
  final String? password;

  EmbyApiClient({
    required this.baseUrl,
    this.apiKey,
    this.userId,
    this.username,
    this.password,
  });

  String get _authHeader => apiKey != null ? 'MediaBrowser Client="E 宝盒", Version="5.0.0", DeviceId="ebox-client", Token="$apiKey"' : '';
  
  String get imageUrl {
    if (apiKey != null) {
      return '$baseUrl/Items/[ITEM_ID]/Images/Primary?Tag=[TAG]&MaxWidth=400&api_key=$apiKey';
    }
    return '$baseUrl/Items/[ITEM_ID]/Images/Primary?Tag=[TAG]&MaxWidth=400';
  }

  String get backdropUrl {
    if (apiKey != null) {
      return '$baseUrl/Items/[ITEM_ID]/Images/Backdrop?MaxWidth=1920&api_key=$apiKey';
    }
    return '$baseUrl/Items/[ITEM_ID]/Images/Backdrop?MaxWidth=1920';
  }

  /// 获取用户视图（媒体库）
  Future<List<UserView>> getUserViews() async {
    try {
      final url = Uri.parse('$baseUrl/Users/$userId/Views?api_key=$apiKey');
      final response = await http.get(url, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List? ?? [];
        return items.map((item) => UserView.fromJson(item)).toList();
      } else {
        debugPrint('获取用户视图失败：${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('获取用户视图异常：$e');
      return [];
    }
  }

  /// 获取媒体库项目
  Future<List<MediaItem>> getLibraryItems({
    String? parentId,
    String? includeItemTypes,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'SortBy': 'SortName',
        'SortOrder': 'Ascending',
        'IncludeItemTypes': includeItemTypes ?? 'Movie,Series,Episode',
        'Recursive': 'true',
        'Limit': limit.toString(),
        'StartIndex': '0',
        'ImageTypeLimit': '1',
        'EnableImageTypes': 'Primary,Backdrop',
      };

      if (parentId != null && parentId.isNotEmpty) {
        queryParams['ParentId'] = parentId;
      }

      final uri = Uri.parse('$baseUrl/Items').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List? ?? [];
        return items.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        debugPrint('获取媒体库失败：${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('获取媒体库异常：$e');
      return [];
    }
  }

  /// 获取继续观看的项目
  Future<List<MediaItem>> getResumeItems({int limit = 50}) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'Limit': limit.toString(),
        'SortBy': 'DatePlayed',
        'SortOrder': 'Descending',
        'IncludeItemTypes': 'Movie,Episode',
        'Recursive': 'true',
        'IsPlayed': 'false',
        'ImageTypeLimit': '1',
        'EnableImageTypes': 'Primary,Backdrop',
      };

      final uri = Uri.parse('$baseUrl/Users/$userId/Items/Resume').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List? ?? [];
        return items.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        debugPrint('获取续播项目失败：${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('获取续播项目异常：$e');
      return [];
    }
  }

  /// 获取最近添加的项目
  Future<List<MediaItem>> getRecentlyAdded({int limit = 50}) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'Limit': limit.toString(),
        'SortBy': 'DateCreated,SortName',
        'SortOrder': 'Descending',
        'IncludeItemTypes': 'Movie,Series,Episode',
        'Recursive': 'true',
        'ImageTypeLimit': '1',
        'EnableImageTypes': 'Primary,Backdrop',
      };

      final uri = Uri.parse('$baseUrl/Users/$userId/Items/Latest').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List? ?? [];
        return items.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        debugPrint('获取最近添加失败：${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('获取最近添加异常：$e');
      return [];
    }
  }

  /// 获取项目详情
  Future<MediaItem?> getItemById(String itemId) async {
    try {
      final url = Uri.parse('$baseUrl/Items/$itemId?api_key=$apiKey');
      final response = await http.get(url, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MediaItem.fromJson(data);
      } else {
        debugPrint('获取项目详情失败：${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('获取项目详情异常：$e');
      return null;
    }
  }

  /// 搜索
  Future<List<MediaItem>> search({
    String? query,
    List<String>? includeItemTypes,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'Query': query ?? '',
        'Limit': limit.toString(),
        'IncludeItemTypes': includeItemTypes?.join(',') ?? 'Movie,Series,Episode,Person',
      };

      final uri = Uri.parse('$baseUrl/Items').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List? ?? [];
        return items.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        debugPrint('搜索失败：${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('搜索异常：$e');
      return [];
    }
  }

  /// 更新播放进度
  Future<void> updatePlayState(String itemId, {
    Duration? position,
    Duration? runtime,
    bool isPaused = false,
  }) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'PositionTicks': ((position?.inMilliseconds ?? 0) * 10000).toString(),
      };

      if (isPaused) {
        final uri = Uri.parse('$baseUrl/Sessions/Playing/Paused').replace(queryParameters: queryParams);
        await http.post(uri, headers: {
          'X-Emby-Authorization': _authHeader,
          'Content-Type': 'application/json',
        }).timeout(const Duration(seconds: 5));
      } else {
        final uri = Uri.parse('$baseUrl/Sessions/Playing/Progress').replace(queryParameters: queryParams);
        await http.post(uri, headers: {
          'X-Emby-Authorization': _authHeader,
          'Content-Type': 'application/json',
        }).timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      debugPrint('更新播放进度异常：$e');
      // 不抛出异常，避免影响播放
    }
  }

  /// 标记为已播放
  Future<void> markPlayed(String itemId) async {
    try {
      final url = Uri.parse('$baseUrl/Users/$userId/PlayedItems/$itemId?api_key=$apiKey');
      await http.post(url, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('标记已播放异常：$e');
    }
  }

  /// 标记为未播放
  Future<void> markUnplayed(String itemId) async {
    try {
      final url = Uri.parse('$baseUrl/Users/$userId/PlayedItems/$itemId?api_key=$apiKey');
      await http.delete(url, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('标记未播放异常：$e');
    }
  }

  /// 获取剧集详情
  Future<List<MediaItem>> getEpisodes(String seriesId) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'SeriesId': seriesId,
        'SortBy': 'SortName',
        'SortOrder': 'Ascending',
        'ImageTypeLimit': '1',
        'EnableImageTypes': 'Primary',
      };

      final uri = Uri.parse('$baseUrl/Shows/$seriesId/Episodes').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data['Items'] as List?) ?? [];
        return items.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        debugPrint('获取剧集失败：${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('获取剧集异常：$e');
      return [];
    }
  }

  /// 获取季列表
  Future<List<MediaItem>> getSeasons(String seriesId) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'SortBy': 'SortName',
        'SortOrder': 'Ascending',
        'ImageTypeLimit': '1',
        'EnableImageTypes': 'Primary',
      };

      final uri = Uri.parse('$baseUrl/Shows/$seriesId/Seasons').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data['Items'] as List?) ?? [];
        return items.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        debugPrint('获取季列表失败：${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('获取季列表异常：$e');
      return [];
    }
  }

  /// 获取媒体源信息（用于播放）
  Future<Map<String, dynamic>?> getPlaybackInfo(String itemId) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'StartTimeTicks': '0',
        'UserId': userId ?? '',
        'AutoOpenLiveStream': 'true',
        'IsPlayback': 'true',
        'MaxStreamingBitrate': '100000000',
      };

      final uri = Uri.parse('$baseUrl/Items/$itemId/PlaybackInfo').replace(queryParameters: queryParams);
      final response = await http.post(uri, headers: {
        'X-Emby-Authorization': _authHeader,
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('获取播放信息失败：${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('获取播放信息异常：$e');
      return null;
    }
  }

  /// 获取直播流信息
  Future<Map<String, dynamic>?> getLiveStreamMediaSource(String playSessionId) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'PlaySessionId': playSessionId,
      };

      final uri = Uri.parse('$baseUrl/LiveStreams/Open').replace(queryParameters: queryParams);
      final response = await http.post(uri, headers: {
        'X-Emby-Authorization': _authHeader,
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('获取直播流失败：${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('获取直播流异常：$e');
      return null;
    }
  }

  /// 停止播放
  Future<void> stopPlayback(String itemId, {Duration? position}) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'PositionTicks': ((position?.inMilliseconds ?? 0) * 10000).toString(),
      };

      final uri = Uri.parse('$baseUrl/Sessions/Playing/Stopped').replace(queryParameters: queryParams);
      await http.post(uri, headers: {
        'X-Emby-Authorization': _authHeader,
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('停止播放异常：$e');
    }
  }

  /// 测试连接
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/System/Info?api_key=$apiKey');
      final response = await http.get(url, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('连接测试异常：$e');
      return false;
    }
  }

  /// 获取用户信息
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final url = Uri.parse('$baseUrl/Users/$userId?api_key=$apiKey');
      final response = await http.get(url, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('获取用户信息失败：${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('获取用户信息异常：$e');
      return null;
    }
  }

  /// 搜索电影
  Future<List<MediaItem>> searchMovies(String query, {int limit = 20}) async {
    return search(query: query, includeItemTypes: ['Movie'], limit: limit);
  }

  /// 搜索剧集
  Future<List<MediaItem>> searchSeries(String query, {int limit = 20}) async {
    return search(query: query, includeItemTypes: ['Series'], limit: limit);
  }

  /// 获取推荐项目
  Future<List<MediaItem>> getRecommendations({int limit = 20}) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'Limit': limit.toString(),
        'ImageTypeLimit': '1',
        'EnableImageTypes': 'Primary,Backdrop',
      };

      final uri = Uri.parse('$baseUrl/Users/$userId/Recommendations').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data['Items'] as List?) ?? [];
        return items.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        debugPrint('获取推荐失败：${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('获取推荐异常：$e');
      return [];
    }
  }

  /// 获取类似项目
  Future<List<MediaItem>> getSimilarItems(String itemId, {int limit = 20}) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'Limit': limit.toString(),
        'ImageTypeLimit': '1',
        'EnableImageTypes': 'Primary',
      };

      final uri = Uri.parse('$baseUrl/Items/$itemId/Similar').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data['Items'] as List?) ?? [];
        return items.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        debugPrint('获取类似项目失败：${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('获取类似项目异常：$e');
      return [];
    }
  }

  /// 获取工作室作品
  Future<List<MediaItem>> getStudioItems(String studioId, {int limit = 20}) async {
    return getLibraryItems(parentId: studioId, limit: limit);
  }

  /// 获取艺术家作品
  Future<List<MediaItem>> getArtistItems(String artistId, {int limit = 20}) async {
    return getLibraryItems(parentId: artistId, limit: limit);
  }

  /// 获取类型项目
  Future<List<MediaItem>> getGenreItems(String genre, {int limit = 20}) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'Genre': genre,
        'Limit': limit.toString(),
        'Recursive': 'true',
        'ImageTypeLimit': '1',
        'EnableImageTypes': 'Primary',
      };

      final uri = Uri.parse('$baseUrl/Items').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data['Items'] as List?) ?? [];
        return items.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        debugPrint('获取类型项目失败：${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('获取类型项目异常：$e');
      return [];
    }
  }
}
