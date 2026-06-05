import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/emby_server.dart';
import '../models/user.dart';
import '../models/media_library.dart';
import '../models/media_item.dart';

class EmbyApiClient {
  final Dio _dio = Dio();
  String? _baseUrl;
  String? _accessToken;
  String? _userId;
  User? _currentUser;

  String? get baseUrl => _baseUrl;
  String? get accessToken => _accessToken;
  String? get userId => _userId;
  User? get currentUser => _currentUser;
  Dio get dio => _dio;

  Future<bool> testConnection(String url) async {
    try {
      final response = await _dio.get(
        '$url/System/Info/Public',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getPublicInfo(String url) async {
    try {
      final response = await _dio.get('$url/System/Info/Public');
      return response.data;
    } catch (e) {
      throw Exception('无法获取服务器信息：$e');
    }
  }

  Future<User> authenticate(String url, String username, String password) async {
    try {
      final response = await _dio.post(
        '$url/Users/AuthenticateByName',
        data: jsonEncode({
          'Username': username,
          'Pw': password,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Emby-Authorization': _buildAuthHeader(),
          },
        ),
      );

      final data = response.data;
      
      _baseUrl = url;
      _accessToken = data['AccessToken'];
      _userId = data['User']['Id'];
      
      _currentUser = User.fromJson(data['User']);

      return _currentUser!;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception('用户名或密码错误');
      }
      throw Exception('认证失败：$e');
    }
  }

  String _buildAuthHeader() {
    return 'MediaBrowser Client="E 宝盒", Device="Windows", '
        'DeviceId="ebox-windows-${DateTime.now().millisecondsSinceEpoch}", '
        'Version="2.0.0"';
  }

  Future<List<MediaLibrary>> getLibraries(String userId) async {
    if (_baseUrl == null || _accessToken == null) {
      throw Exception('请先连接到 Emby 服务器');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/Users/$userId/Items?Recursive=true&StartIndex=0&Limit=100&SortBy=SortName&SortOrder=Ascending',
        options: Options(
          headers: {
            'X-MediaBrowser-Token': _accessToken!,
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['Items'] as List?;
        if (items != null) {
          return items
              .map((item) => MediaLibrary(
                    id: item['Id'] as String,
                    name: item['Name'] as String,
                    type: _mapLibraryType(item['CollectionType'] as String?),
                  ))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('获取媒体库失败：$e');
    }
  }

  String _mapLibraryType(String? collectionType) {
    switch (collectionType?.toLowerCase()) {
      case 'movies':
        return 'movie';
      case 'tvshows':
        return 'tvshow';
      case 'music':
        return 'music';
      case 'musicvideos':
        return 'musicvideo';
      default:
        return 'unknown';
    }
  }

  Future<List<MediaItem>> getLibraryItems({
    required String libraryId,
    String? parentId,
    int startIndex = 0,
    int limit = 100,
    String mediaType = 'Movie',
  }) async {
    if (_baseUrl == null || _accessToken == null) {
      throw Exception('请先连接到 Emby 服务器');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/Users/$_userId/Items',
        queryParameters: {
          'UserId': _userId,
          'Recursive': 'true',
          'StartIndex': startIndex.toString(),
          'Limit': limit.toString(),
          'SortBy': 'SortName',
          'SortOrder': 'Ascending',
          if (parentId != null) 'ParentId': parentId,
        },
        options: Options(
          headers: {
            'X-MediaBrowser-Token': _accessToken!,
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['Items'] as List?;
        if (items != null) {
          return items.map((item) => MediaItem.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('获取媒体项失败：$e');
    }
  }

  Future<MediaItem> getItemDetail(String itemId) async {
    if (_baseUrl == null || _accessToken == null) {
      throw Exception('请先连接到 Emby 服务器');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/Users/$_userId/Items/$itemId',
        queryParameters: {'userId': _userId},
        options: Options(
          headers: {
            'X-MediaBrowser-Token': _accessToken!,
            'Accept': 'application/json',
          },
        ),
      );

      return MediaItem.fromJson(response.data);
    } catch (e) {
      throw Exception('获取媒体详情失败：$e');
    }
  }

  Future<List<MediaItem>> getSeasons(String seriesId, String seasonId) async {
    if (_baseUrl == null || _accessToken == null) {
      throw Exception('请先连接到 Emby 服务器');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/Shows/$seriesId/Episodes',
        queryParameters: {
          'userId': _userId,
          'seasonId': seasonId,
          'fields': 'Overview,PrimaryImageAspectRatio',
        },
        options: Options(
          headers: {
            'X-MediaBrowser-Token': _accessToken!,
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['Items'] != null) {
        return (data['Items'] as List).map((item) => MediaItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('获取剧集列表失败：$e');
    }
  }

  Future<MediaItem> getEpisodeDetail(String seriesId, String seasonId, String episodeId) async {
    return await getItemDetail(episodeId);
  }

  Future<String> getPlaybackUrl(String itemId, {bool isDirectPlay = false}) async {
    if (_baseUrl == null || _accessToken == null) {
      throw Exception('请先连接到 Emby 服务器');
    }

    final response = await _dio.get(
      '$_baseUrl/Items/$itemId',
      queryParameters: {
        'userId': _userId,
        'fields': 'MediaSources',
      },
      options: Options(
        headers: {
          'X-MediaBrowser-Token': _accessToken!,
          'Accept': 'application/json',
        },
      ),
    );

    final mediaSources = (response.data['MediaSources'] as List?)?.first;
    if (mediaSources == null || mediaSources['DirectStreamUrl'] == null) {
      throw Exception('无法获取播放地址');
    }

    final url = mediaSources['DirectStreamUrl'] ?? mediaSources['StaticStreamUrl'];
    
    if (!url.startsWith('http')) {
      return '$_baseUrl$url?api_key=$_accessToken';
    }
    
    return url;
  }

  Future<void> reportPlaybackStart(String itemId) async {
    if (_baseUrl == null || _accessToken == null) return;
    try {
      await _dio.post(
        '$_baseUrl/Sessions/Playing',
        data: {
          'ItemId': itemId,
          'ServerId': _baseUrl,
          'MediaSourceId': itemId,
          'PositionTicks': 0,
        },
        options: Options(
          headers: {
            'X-MediaBrowser-Token': _accessToken!,
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {}
  }

  Future<void> reportPlaybackProgress(String itemId, Duration position) async {
    if (_baseUrl == null || _accessToken == null) return;
    try {
      await _dio.post(
        '$_baseUrl/Sessions/Playing/Progress',
        data: {
          'ItemId': itemId,
          'ServerId': _baseUrl,
          'MediaSourceId': itemId,
          'PositionTicks': position.inMilliseconds * 10000,
        },
        options: Options(
          headers: {
            'X-MediaBrowser-Token': _accessToken!,
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {}
  }

  Future<void> reportPlaybackStopped(String itemId, Duration position) async {
    if (_baseUrl == null || _accessToken == null) return;
    try {
      await _dio.post(
        '$_baseUrl/Sessions/Playing/Stopped',
        data: {
          'ItemId': itemId,
          'ServerId': _baseUrl,
          'MediaSourceId': itemId,
          'PositionTicks': position.inMilliseconds * 10000,
        },
        options: Options(
          headers: {
            'X-MediaBrowser-Token': _accessToken!,
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {}
  }

  Future<void> markPlayed(String itemId) async {
    if (_baseUrl == null || _accessToken == null) return;
    try {
      await _dio.post('$_baseUrl/Users/$_userId/PlayedItems/$itemId');
    } catch (e) {}
  }

  Future<void> markUnplayed(String itemId) async {
    if (_baseUrl == null || _accessToken == null) return;
    try {
      await _dio.delete('$_baseUrl/Users/$_userId/PlayedItems/$itemId');
    } catch (e) {}
  }

  Future<List<MediaItem>> search(String query, {List<String>? types}) async {
    if (_baseUrl == null || _accessToken == null) {
      throw Exception('请先连接到 Emby 服务器');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/Users/$_userId/Items',
        queryParameters: {
          'searchTerm': query,
          'Recursive': 'true',
          'Limit': '50',
          if (types != null) 'IncludeItemTypes': types.join(','),
        },
        options: Options(
          headers: {
            'X-MediaBrowser-Token': _accessToken!,
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['Items'] != null) {
        return (data['Items'] as List).map((item) => MediaItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('搜索失败：$e');
    }
  }

  Future<List<MediaItem>> getRecentlyAdded({String? parentId, int limit = 20}) async {
    if (_baseUrl == null || _accessToken == null) {
      throw Exception('请先连接到 Emby 服务器');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/Users/$_userId/Items/Latest',
        queryParameters: {
          'Limit': limit.toString(),
          if (parentId != null) 'ParentId': parentId,
        },
        options: Options(
          headers: {
            'X-MediaBrowser-Token': _accessToken!,
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data;
      if (data is List) {
        return data.map((item) => MediaItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('获取最近添加失败：$e');
    }
  }

  Future<List<MediaItem>> getResumeItems({String? parentId, int limit = 20}) async {
    if (_baseUrl == null || _accessToken == null) {
      throw Exception('请先连接到 Emby 服务器');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/Users/$_userId/Items/Resume',
        queryParameters: {
          'Limit': limit.toString(),
          if (parentId != null) 'ParentId': parentId,
        },
        options: Options(
          headers: {
            'X-MediaBrowser-Token': _accessToken!,
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['Items'] != null) {
        return (data['Items'] as List).map((item) => MediaItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('获取续播项目失败：$e');
    }
  }
}
